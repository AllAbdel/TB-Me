import 'package:flutter/material.dart';
import 'dart:async';
import '../providers/language_provider.dart';
import '../services/catchup_service.dart';
import '../services/notification_service.dart';

class CatchupTimerPage extends StatefulWidget {
  final Map<String, dynamic> medicament;

  const CatchupTimerPage({super.key, required this.medicament});

  @override
  _CatchupTimerPageState createState() => _CatchupTimerPageState();
}

class _CatchupTimerPageState extends State<CatchupTimerPage> {
  final LanguageProvider _languageProvider = LanguageProvider();
  Timer? _timer;
  Duration _remainingTime = const Duration(hours: 2);
  bool _isCompleted = false;
  DateTime? _endTime;

  String _tr(String key) {
    return _languageProvider.translate(key);
  }

  @override
  void initState() {
    super.initState();
    _loadCatchupData();
  }

  Future<void> _loadCatchupData() async {
    // Charger les données de rattrapage existantes
    final catchups = await CatchupService.getActiveCatchups();
    final existingCatchup = catchups.firstWhere(
      (c) => c['medicationId'] == widget.medicament['id'],
      orElse: () => {},
    );

    if (existingCatchup.isNotEmpty) {
      // Rattrapage existant - calculer le temps restant
      _endTime = DateTime.fromMillisecondsSinceEpoch(existingCatchup['endTime']);
      _calculateRemainingTime();
    } else {
      // Nouveau rattrapage - créer et programmer notification
      _endTime = DateTime.now().add(const Duration(hours: 2));
      await _programmerNotificationRattrapage();
    }
    
    _startTimer();
  }

  Future<void> _programmerNotificationRattrapage() async {
    // Programmer une notification quand les 2h sont écoulées
    await NotificationService.showCatchupComplete(
      baseId: widget.medicament['id'],
      medicamentNom: widget.medicament['nom'],
      dosage: widget.medicament['dosage'],
      scheduledTime: _endTime!,
    );
  }

  void _calculateRemainingTime() {
    final now = DateTime.now();
    if (_endTime!.isAfter(now)) {
      setState(() {
        _remainingTime = _endTime!.difference(now);
      });
    } else {
      setState(() {
        _isCompleted = true;
        _remainingTime = Duration.zero;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_endTime != null) {
        _calculateRemainingTime();
        
        if (_remainingTime.inSeconds <= 0) {
          setState(() {
            _isCompleted = true;
          });
          timer.cancel();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tr('catch_up.timer_title')),
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple[50]!,
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isCompleted) ...[
                  Icon(Icons.timer, size: 80, color: Colors.purple[600]),
                  const SizedBox(height: 20),
                  Text(
                    _tr('catch_up.timer_subtitle'),
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Text(
                      _formatDuration(_remainingTime),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.no_food, size: 40, color: Colors.orange[700]),
                        const SizedBox(height: 10),
                        Text(
                          _tr('catch_up.fasting_rules'),
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Icon(Icons.check_circle, size: 100, color: Colors.green[600]),
                  const SizedBox(height: 20),
                  Text(
                    _tr('catch_up.ready_title'),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _tr('catch_up.ready_message'),
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${widget.medicament['nom']} ${widget.medicament['dosage']}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${widget.medicament['nombreComprimes']} comprimé(s)',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      // Marquer comme pris et supprimer le rattrapage
                      await CatchupService.removeCatchup(widget.medicament['id']);
                      
                      // Message d'encouragement
                      final encouragements = _languageProvider.getEncouragementList('encouragement.regular_taking');

                      final message = CatchupService.getRandomEncouragement(encouragements);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                      
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    child: Text(
                      _tr('catch_up.take_now'),
                      style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                const SizedBox(height: 40),
                TextButton(
                  onPressed: () async {
                    await CatchupService.removeCatchup(widget.medicament['id']);
                    Navigator.pop(context);
                  },
                  child: Text(
                    _tr('catch_up.cancel_catchup'),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}