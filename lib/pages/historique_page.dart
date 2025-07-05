import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../providers/language_provider.dart';


class HistoriquePage extends StatefulWidget {
  const HistoriquePage({super.key});


  @override
  _HistoriquePageState createState() => _HistoriquePageState();
}

class _HistoriquePageState extends State<HistoriquePage> {
  DateTime? _installationDate;
  final LanguageProvider _languageProvider = LanguageProvider();
  DateTime _selectedWeek = DateTime.now();
  Map<String, List<Map<String, dynamic>>> _weeklyData = {};
  List<Map<String, dynamic>> _posology = [];

  String _tr(String key) => _languageProvider.translate(key);

  @override
  void initState() {
    super.initState();
    _loadWeeklyData();
    _loadPosology();
  }

  Future<void> _setInstallationDate() async {
  final prefs = await SharedPreferences.getInstance();
  
  // OPTION 1: Forcer la date d'installation à aujourd'hui (pour test)
  final today = DateTime.now();
  final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
  
  // DÉCOMMENTER CETTE LIGNE POUR FORCER LA RÉINITIALISATION :
  // await prefs.remove('installation_date');
  
  String? installationDateString = prefs.getString('installation_date');
  
  if (installationDateString == null) {
    await prefs.setString('installation_date', dateKey);
    print('📅 Date d\'installation enregistrée: $dateKey');
    
    setState(() {
      _installationDate = today;
    });
  } else {
    final parts = installationDateString.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);
    
    setState(() {
      _installationDate = DateTime(year, month, day);
    });
    
    print('📅 Date d\'installation récupérée: $installationDateString');
  }
}

  Future<void> _loadPosology() async {
    final prefs = await SharedPreferences.getInstance();
    final String? posologieJson = prefs.getString('ma_posologie');
    if (posologieJson != null) {
      setState(() {
        _posology = List<Map<String, dynamic>>.from(json.decode(posologieJson));
      });
    }
  }

  Future<void> _loadWeeklyData() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, List<Map<String, dynamic>>> weekData = {};
    
    // Charger les données de la semaine sélectionnée
    DateTime startOfWeek = _selectedWeek.subtract(Duration(days: _selectedWeek.weekday - 1));
    
    for (int i = 0; i < 7; i++) {
      DateTime day = startOfWeek.add(Duration(days: i));
      String dateKey = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      
      String? dayData = prefs.getString('prises_$dateKey');
      if (dayData != null) {
        weekData[dateKey] = List<Map<String, dynamic>>.from(json.decode(dayData));
      } else {
        weekData[dateKey] = [];
      }
    }
    
    setState(() {
      _weeklyData = weekData;
    });
  }

  void _changeWeek(int direction) {
    setState(() {
      _selectedWeek = _selectedWeek.add(Duration(days: direction * 7));
    });
    _loadWeeklyData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tr('history.title')),
        backgroundColor: Colors.teal[600],
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal[50]!, Colors.white],
          ),
        ),
        child: Column(
          children: [
            // Navigation semaine
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => _changeWeek(-1),
                    icon: Icon(Icons.arrow_back_ios, color: Colors.teal[700]),
                  ),
                  Text(
                    '${_tr('history.week_of')} ${_getWeekRange()}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal[700]),
                  ),
                  IconButton(
                    onPressed: () => _changeWeek(1),
                    icon: Icon(Icons.arrow_forward_ios, color: Colors.teal[700]),
                  ),
                ],
              ),
            ),
            // Grille des jours
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: 4,
                  mainAxisSpacing: 12,
                ),
                itemCount: 7,
                itemBuilder: (context, index) {
                  DateTime day = _selectedWeek.subtract(Duration(days: _selectedWeek.weekday - 1)).add(Duration(days: index));
                  String dateKey = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
                  List<Map<String, dynamic>> dayData = _weeklyData[dateKey] ?? [];
                  
                  return _buildDayCard(day, dayData);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildDayCard(DateTime day, List<Map<String, dynamic>> dayData) {
List<String> dayNames = [
  _tr('date.monday_short'), 
  _tr('date.tuesday_short'), 
  _tr('date.wednesday_short'), 
  _tr('date.thursday_short'), 
  _tr('date.friday_short'), 
  _tr('date.saturday_short'), 
  _tr('date.sunday_short')
];  DateTime today = DateTime.now();
  DateTime todayOnly = DateTime(today.year, today.month, today.day);
  DateTime dayOnly = DateTime(day.year, day.month, day.day);
  
  // NOUVEAU : Vérifier si le jour est avant l'installation
  if (_installationDate != null) {
    DateTime installationOnly = DateTime(_installationDate!.year, _installationDate!.month, _installationDate!.day);
    
    if (dayOnly.isBefore(installationOnly)) {
      // Jour avant l'installation - ne pas compter
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Date
              SizedBox(
                width: 60,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dayNames[day.weekday - 1],
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                    Text(
                      '${day.day}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Message
              Expanded(
                child: Center(
                  child: Text(
                    _tr('history.before_installation'),
                    style: TextStyle(
                      fontSize: 14, 
                      color: Colors.grey[500], 
                      fontStyle: FontStyle.italic
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
  
  // Logique normale pour les jours après l'installation
  int taken = 0;
  int missed = 0;
  String statusText = '';
  
  if (dayOnly.isAfter(todayOnly)) {
    // Jour futur
    statusText = _tr('history.upcoming');
  } else if (dayOnly.isBefore(todayOnly)) {
    // Jour passé (mais après l'installation)
    taken = dayData.where((d) => d['pris'] == true).length;
    int expectedMedications = _getExpectedMedicationsForDay(day);
    missed = expectedMedications - taken;
    statusText = '';
  } else {
    // Aujourd'hui
    taken = dayData.where((d) => d['pris'] == true).length;
    int expectedMedications = _posology.length;
    missed = expectedMedications - taken;
    statusText = '';
  }

  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Date
          SizedBox(
            width: 60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dayNames[day.weekday - 1],
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  '${day.day}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal[700]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Statistiques
          Expanded(
            child: statusText.isNotEmpty
                ? Center(
                    child: Text(
                      statusText,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600], fontStyle: FontStyle.italic),
                    ),
                  )
                : Row(
                    children: [
                      _buildStatChip(_tr('history.taken_count').replaceAll('{count}', taken.toString()), Colors.green),
                      const SizedBox(width: 8),
                      if (missed > 0) _buildStatChip(_tr('history.missed_count').replaceAll('{count}', missed.toString()), Colors.red),
                    ]
                  ),
          ),
          // Détails (seulement pour les jours passés/présents après installation)
          if (statusText.isEmpty)
            IconButton(
              onPressed: () => _showDayDetails(day, dayData),
              icon: Icon(Icons.info_outline, color: Colors.teal[600]),
            ),
        ],
      ),
    ),
  );
}

int _getExpectedMedicationsForDay(DateTime day) {
  // Retourner le nombre de médicaments attendus pour ce jour
  // Pour simplifier, on assume que la posologie actuelle était la même
  return _posology.length;
}
  Widget _buildStatChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showDayDetails(DateTime day, List<Map<String, dynamic>> dayData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${_tr('history.details_title')} ${day.day}/${day.month}'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: dayData.isEmpty
            ? Center(child: Text(_tr('history.no_data')))
              : ListView.builder(
                  itemCount: dayData.length,
                  itemBuilder: (context, index) {
                    final prise = dayData[index];
                    final medicament = _posology.firstWhere(
                      (m) => m['id'].toString() == prise['medicamentId'].toString(),
                    orElse: () => {'nom': _tr('history.unknown_medication'), 'dosage': ''},
                    );
                    
                    return ListTile(
                      leading: Icon(
                        prise['pris'] ? Icons.check_circle : Icons.cancel,
                        color: prise['pris'] ? Colors.green : Colors.red,
                      ),
                      title: Text('${medicament['nom']} ${medicament['dosage']}'),
                    subtitle: Text(prise['pris'] ? '${_tr('history.taken_at')} ${prise['heurePrise']}' : _tr('history.missed')),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_tr('common.close')),          ),
        ],
      ),
    );
  }

  String _getWeekRange() {
    DateTime startOfWeek = _selectedWeek.subtract(Duration(days: _selectedWeek.weekday - 1));
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
    return '${startOfWeek.day}/${startOfWeek.month} - ${endOfWeek.day}/${endOfWeek.month}';
  }
}