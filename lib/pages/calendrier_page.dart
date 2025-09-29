import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../providers/language_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../services/notification_service.dart';
import 'package:table_calendar/table_calendar.dart';
import '../widgets/credits_widget.dart';

class CalendrierPage extends StatefulWidget {
  const CalendrierPage({Key? key}) : super(key: key);

  @override
  State<CalendrierPage> createState() => _CalendrierPageState();
}

class Event {
  String title;
  String description;
  TimeOfDay time;
  bool notify;
  Event({required this.title, required this.description, required this.time, this.notify = false});

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'time': '${time.hour}:${time.minute}',
    'notify': notify,
  };
  
  static Event fromJson(Map<String, dynamic> json) {
    final timeParts = (json['time'] as String).split(':');
    return Event(
      title: json['title'],
      description: json['description'],
      time: TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1])),
      notify: json['notify'] ?? false,
    );
  }
}

class _CalendrierPageState extends State<CalendrierPage> {
  final LanguageProvider _languageProvider = LanguageProvider();
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<String, List<Event>> _events = {};
  final TextEditingController _eventTitleController = TextEditingController();
  final TextEditingController _eventDescController = TextEditingController();
  TimeOfDay? _selectedTime;
  bool _notify = false;

  final ScrollController _eventsController = ScrollController();
  final ScrollController _allEventsController = ScrollController();

  String _tr(String key) => _languageProvider.translate(key);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadEvents();
  }

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String? eventsJson = prefs.getString('calendar_events');
    if (eventsJson != null) {
      final decoded = json.decode(eventsJson);
      final Map<String, List<Event>> loaded = {};
      decoded.forEach((k, v) {
        if (v is List) {
          final List<Event> events = v.map((e) {
            if (e is String) {
              return Event(title: e, description: '', time: const TimeOfDay(hour: 12, minute: 0));
            } else if (e is Map<String, dynamic> || e is Map) {
              return Event.fromJson(Map<String, dynamic>.from(e));
            } else {
              return Event(title: e.toString(), description: '', time: const TimeOfDay(hour: 12, minute: 0));
            }
          }).toList();
          loaded[k] = events;
        }
      });
      setState(() {
        _events = loaded;
      });
    }
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final map = _events.map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList()));
    await prefs.setString('calendar_events', json.encode(map));
  }

  void _addEvent() async {
    final title = _eventTitleController.text.trim();
    final desc = _eventDescController.text.trim();
    if (title.isEmpty || _selectedTime == null) return;
    final key = _dateKey(_selectedDate);
    final event = Event(title: title, description: desc, time: _selectedTime!, notify: _notify);
    setState(() {
      if (_events.containsKey(key)) {
        _events[key]!.add(event);
      } else {
        _events[key] = [event];
      }
      _eventTitleController.clear();
      _eventDescController.clear();
      _selectedTime = null;
      _notify = false;
    });
    await _saveEvents();
    if (event.notify) {
      final now = DateTime.now();
      final eventDateTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, event.time.hour, event.time.minute);
      if (eventDateTime.isAfter(now)) {
        await NotificationService.notifications.zonedSchedule(
          event.hashCode,
          event.title,
          event.description,
          tz.TZDateTime.from(eventDateTime, tz.local),
          NotificationDetails(
            android: AndroidNotificationDetails(
              'calendar_events',
              'Événements calendrier',
              channelDescription: 'Notifications des événements du calendrier',
              importance: Importance.max,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }

  void _deleteEvent(int index) {
    final key = _dateKey(_selectedDate);
    final event = _events[key]![index];
    setState(() {
      _events[key]!.removeAt(index);
      if (_events[key]!.isEmpty) {
        _events.remove(key);
      }
    });
    _saveEvents();
    NotificationService.cancelNotification(event.hashCode);
  }

  String _dateKey(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  List<Event> _getEventsForDay(DateTime day) {
    final key = _dateKey(day);
    return _events[key] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final key = _dateKey(_selectedDate);
    final events = _events[key] ?? [];
    final allEvents = _events.entries.expand((e) => e.value.map((ev) => MapEntry(e.key, ev))).toList();
    allEvents.sort((a, b) {
      final d1 = DateTime.parse(a.key);
      final d2 = DateTime.parse(b.key);
      final t1 = a.value.time;
      final t2 = b.value.time;
      return d1.compareTo(d2) != 0 ? d1.compareTo(d2) : (t1.hour * 60 + t1.minute).compareTo(t2.hour * 60 + t2.minute);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(_tr('calendar.title')),
        backgroundColor: const Color(0xFF1565C0),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF1E88E5), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Card(
                  margin: const EdgeInsets.all(16),
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: TableCalendar(
                      firstDay: DateTime(2000),
                      lastDay: DateTime(2100),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDate = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      eventLoader: _getEventsForDay,
                      calendarFormat: CalendarFormat.month,
                      locale: _languageProvider.currentLanguage,
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextFormatter: (date, locale) {
                          final monthNames = [
                            _tr('date.january'), _tr('date.february'), _tr('date.march'),
                            _tr('date.april'), _tr('date.may'), _tr('date.june'),
                            _tr('date.july'), _tr('date.august'), _tr('date.september'),
                            _tr('date.october'), _tr('date.november'), _tr('date.december')
                          ];
                          return '${monthNames[date.month - 1]} ${date.year}';
                        },
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        dowTextFormatter: (date, locale) {
                          final dayNames = [
                            _tr('date.monday_short'), _tr('date.tuesday_short'),
                            _tr('date.wednesday_short'), _tr('date.thursday_short'),
                            _tr('date.friday_short'), _tr('date.saturday_short'),
                            _tr('date.sunday_short')
                          ];
                          return dayNames[date.weekday - 1];
                        },
                      ),
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.blue[300],
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: const BoxDecoration(
                          color: Color(0xFF1565C0),
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _eventTitleController,
                        decoration: InputDecoration(
                          labelText: _tr('calendar.event_title'),
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _eventDescController,
                        decoration: InputDecoration(
                          labelText: _tr('calendar.event_description'),
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.access_time),
                              label: Text(_selectedTime == null 
                                ? _tr('calendar.choose_time') 
                                : _selectedTime!.format(context)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _selectedTime = picked;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Checkbox(
                            value: _notify,
                            onChanged: (v) {
                              setState(() {
                                _notify = v ?? false;
                              });
                            },
                          ),
                          Text(_tr('calendar.notification')),
                          const Spacer(),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: Text(_tr('calendar.add')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1565C0),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: _addEvent,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _tr('calendar.events_today'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(
                  height: 220,
                  child: events.isEmpty
                    ? Center(child: Text(_tr('calendar.no_events_today')))
                    : Scrollbar(
                        thumbVisibility: true,
                        controller: _eventsController,
                        child: ListView.builder(
                          controller: _eventsController,
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            final e = events[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: ListTile(
                                leading: Icon(Icons.event, color: Colors.blue.shade700),
                                title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (e.description.isNotEmpty) Text(e.description),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time, size: 16),
                                        const SizedBox(width: 4),
                                        Text(e.time.format(context)),
                                        if (e.notify) ...[
                                          const SizedBox(width: 8),
                                          const Icon(Icons.notifications_active, color: Colors.blue, size: 16),
                                        ]
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteEvent(index),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _tr('calendar.all_events'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(
                  height: 220,
                  child: allEvents.isEmpty
                    ? Center(child: Text(_tr('calendar.no_events')))
                    : Scrollbar(
                        thumbVisibility: true,
                        controller: _allEventsController,
                        child: ListView.builder(
                          controller: _allEventsController,
                          itemCount: allEvents.length,
                          itemBuilder: (context, index) {
                            final entry = allEvents[index];
                            final date = DateTime.parse(entry.key);
                            final e = entry.value;
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: ListTile(
                                leading: Icon(Icons.event, color: Colors.blue.shade700),
                                title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(DateFormat('dd/MM/yyyy').format(date), style: const TextStyle(fontWeight: FontWeight.bold)),
                                    if (e.description.isNotEmpty) Text(e.description),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time, size: 16),
                                        const SizedBox(width: 4),
                                        Text(e.time.format(context)),
                                        if (e.notify) ...[
                                          const SizedBox(width: 8),
                                          const Icon(Icons.notifications_active, color: Colors.blue, size: 16),
                                        ]
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                ),
                const SizedBox(height: 20),
                const CreditsWidget(),
              ],
            ),
            
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _eventTitleController.dispose();
    _eventDescController.dispose();
    _eventsController.dispose();
    _allEventsController.dispose();
    super.dispose();
  }
}