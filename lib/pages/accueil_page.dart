// ===== lib/pages/accueil_page.dart =====
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../providers/language_provider.dart';
import '../services/catchup_service.dart';
import '../pages/catchup_timer_page.dart';
import '../pages/historique_page.dart';
import '../pages/medicaments_page.dart';


class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});

  @override
  AccueilPageState createState() => AccueilPageState();
}


class AccueilPageState extends State<AccueilPage> with WidgetsBindingObserver {
  final LanguageProvider _languageProvider = LanguageProvider();
  
  String _tr(String key) {
    return _languageProvider.translate(key);
  }
  List<Map<String, dynamic>> medicamentsDisponibles = [
    {
      'nom': 'Rifadine',
      'dosage': '300mg',
      'image': 'assets/medics/RIFADINE 300 mg.jpg',
    },
    {
      'nom': 'Rifater',
      'dosage': '120mg/50mg/300mg',
      'image': 'assets/medics/RIFATER.jpg',
    },
    {
      'nom': 'Rifinah',
      'dosage': '300mg/150mg',
      'image': 'assets/medics/RIFINAH.jpg',
    },
    {
      'nom': 'Dexambutol',
      'dosage': '500mg',
      'image': 'assets/medics/DEXAMBUTOL 500 mg.jpg',
    },
    {
      'nom': 'Myambutol',
      'dosage': '400mg',
      'image': 'assets/medics/MYAMBUTOL 400 mg.jpg',
    },
    {
      'nom': 'Pirilène',
      'dosage': '500mg',
      'image': 'assets/medics/PIRILENE 500 mg.jpg',
    },
    {
      'nom': 'Rimactan',
      'dosage': '300mg',
      'image': 'assets/medics/RIMACTAN 300 mg.jpg',
    },
    {
      'nom': 'Rimifon',
      'dosage': '50mg',
      'image': 'assets/medics/RIMIFON 50 mg.jpg',
    },
    {
      'nom': 'Rimifon',
      'dosage': '150mg',
      'image': 'assets/medics/RIMIFON 150 mg.jpg',
    },
  ];
  
  List<Map<String, dynamic>> maPosologie = [];
  List<Map<String, dynamic>> prisesAujourdhui = [];
  DateTime maintenant = DateTime.now();

  @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addObserver(this);
  _setInstallationDateIfNeeded(); // NOUVEAU
  _loadData();
  _updateTime();
  _startPeriodicRefresh();
}
Future<void> _setInstallationDateIfNeeded() async {
  final prefs = await SharedPreferences.getInstance();
  
  // Vérifier si on a déjà une date d'installation
  String? installationDateString = prefs.getString('installation_date');
  
  if (installationDateString == null) {
    // Première fois - enregistrer aujourd'hui comme date d'installation
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    await prefs.setString('installation_date', dateKey);
    print('📅 Date d\'installation enregistrée depuis l\'accueil: $dateKey');
  }
}


  

void _demarrerRattrapage(Map<String, dynamic> medicament) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple[400]!, Colors.purple[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              const Icon(Icons.access_time, color: Colors.white, size: 30),
              const SizedBox(height: 8),
              Text(
                _tr('catch_up.title'),
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                children: [
                  Icon(Icons.no_food, size: 40, color: Colors.orange[700]),
                  const SizedBox(height: 12),
                  Text(
                    _tr('catch_up.fasting_period'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _tr('catch_up.fasting_duration'),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange[700]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _tr('catch_up.fasting_rules'),
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${medicament['nom']} ${medicament['dosage']}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_tr('common.cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              // Démarrer le rattrapage
              await CatchupService.startCatchup(
                medicationId: medicament['id'],
                medicamentNom: medicament['nom'],
                dosage: medicament['dosage'],
                nombreComprimes: medicament['nombreComprimes'],
                startTime: DateTime.now(),
              );
              
              Navigator.pop(context);
              
              // Afficher un message d'encouragement
              final encouragements = _languageProvider.getEncouragementList('encouragement.missed_recovery');

              final message = CatchupService.getRandomEncouragement(encouragements);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: Colors.purple,
                  duration: const Duration(seconds: 4),
                ),
              );
              
              // Naviguer vers la page de rattrapage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CatchupTimerPage(
                    medicament: medicament,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(_tr('catch_up.button'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      );
    },
  );
}
  void _startPeriodicRefresh() {
    Future.delayed(const Duration(seconds: 60), () {
      if (mounted) {
        _updateTime();
        _loadData();
        _startPeriodicRefresh();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updateTime();
      _loadData(); // Recharger les données quand on revient sur l'app
    }
  }

  void _updateTime() {
    if (mounted) {
      setState(() {
        maintenant = DateTime.now();
      });
    }
  }


  void refreshData() {
    _loadData();
  }

// Nouvelle fonction pour agrandir l'image dans accueil_page.dart
void _agrandirImage(String imagePath, String nomMedicament) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Titre
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    nomMedicament,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                // Image agrandie
                Flexible(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.medication,
                                  color: Color(0xFF6C63FF),
                                  size: 80,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Image non disponible',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                
                // Instructions
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Toucher pour fermer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}



// Fonction pour obtenir les médicaments uniques (éviter les doublons)
List<Map<String, dynamic>> _getUniqueMedications() {
  Map<String, Map<String, dynamic>> uniqueMeds = {};
  for (var med in maPosologie) {
    String key = '${med['nom']}_${med['dosage']}';
    if (!uniqueMeds.containsKey(key)) {
      uniqueMeds[key] = med;
    }
  }
  return uniqueMeds.values.toList();
}


Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Charger la posologie
    final String? posologieJson = prefs.getString('ma_posologie');
    List<Map<String, dynamic>> nouvellePosologie = [];
    if (posologieJson != null) {
      nouvellePosologie = List<Map<String, dynamic>>.from(json.decode(posologieJson));
    }

    // Charger les prises d'aujourd'hui
    final String? prisesJson = prefs.getString('prises_${_getDateKey(maintenant)}');
    List<Map<String, dynamic>> nouvellesPrises = [];
    if (prisesJson != null) {
      nouvellesPrises = List<Map<String, dynamic>>.from(json.decode(prisesJson));
    }

    if (mounted) {
      setState(() {
        maPosologie = nouvellePosologie;
        prisesAujourdhui = nouvellesPrises;
      });
    }
  }

  Future<void> _savePrises() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('prises_${_getDateKey(maintenant)}', json.encode(prisesAujourdhui));
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  StatutPrise _getStatutPrise(Map<String, dynamic> medicament) {
    final heurePrise = _parseHeure(medicament['heure']);
    final maintenant = DateTime.now();
    final heureMaintenant = TimeOfDay.now();
    
    // Vérifier si déjà pris
    final prise = prisesAujourdhui.firstWhere(
      (p) => p['medicamentId'] == medicament['id'] && p['heure'] == medicament['heure'],
      orElse: () => {},
    );
    
    if (prise.isNotEmpty && prise['pris'] == true) {
      return StatutPrise.pris;
    }
    
    // Comparer les heures
    final heureActuelleEnMinutes = heureMaintenant.hour * 60 + heureMaintenant.minute;
    final heurePriseEnMinutes = heurePrise.hour * 60 + heurePrise.minute;
    
    if (heureActuelleEnMinutes < heurePriseEnMinutes) {
      return StatutPrise.aVenir;
    } else if (heureActuelleEnMinutes - heurePriseEnMinutes > 30) {
      // Considéré comme oublié après 30 minutes de retard
      return StatutPrise.oublie;
    } else {
      return StatutPrise.enCours;
    }
  }

  TimeOfDay _parseHeure(String heure) {
    final parts = heure.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Color _getStatutColor(StatutPrise statut) {
    switch (statut) {
      case StatutPrise.pris:
        return Colors.green;
      case StatutPrise.aVenir:
        return Colors.blue;
      case StatutPrise.enCours:
        return Colors.orange;
      case StatutPrise.oublie:
        return Colors.red;
    }
  }

  IconData _getStatutIcon(StatutPrise statut) {
    switch (statut) {
      case StatutPrise.pris:
        return Icons.check_circle;
      case StatutPrise.aVenir:
        return Icons.schedule;
      case StatutPrise.enCours:
        return Icons.notifications_active;
      case StatutPrise.oublie:
        return Icons.warning;
    }
  }

  String _getStatutText(StatutPrise statut) {
  switch (statut) {
    case StatutPrise.pris:
      return _tr('home.status.taken');
    case StatutPrise.aVenir:
      return _tr('home.status.upcoming');
    case StatutPrise.enCours:
      return _tr('home.status.now');
    case StatutPrise.oublie:
      return _tr('home.status.missed');
  }
}

  void _marquerCommePris(Map<String, dynamic> medicament) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF6C63FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                const Icon(Icons.medication, color: Colors.white, size: 30),
                const SizedBox(height: 8),
                Text(
                  _tr('home.confirm_taking'),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${_tr('home.mark_as_taken')} ${medicament['nom']} ?',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  children: [
                    Text('${medicament['nombreComprimes']} ${_tr('home.tablets')}', 
                         style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('${_tr('home.current_stock')}: ${medicament['stock']}', 
                         style: TextStyle(color: Colors.grey[600])),
                    Text('${_tr('home.stock_after')}: ${medicament['stock'] - medicament['nombreComprimes']}', 
                         style: TextStyle(color: Colors.green[600], fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(_tr('common.cancel'), style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _effectuerPrise(medicament);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(_tr('common.confirm'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

void _effectuerPrise(Map<String, dynamic> medicament) async {
    // Trouver le bon médicament dans la posologie pour décrémenter le stock
    final index = maPosologie.indexWhere((m) => m['id'] == medicament['id']);
    if (index == -1) return; // Sécurité au cas où le médicament n'existe plus
    
    // Vérifier si on a assez de stock
    final stockActuel = maPosologie[index]['stock'] as int;
    final nombreAPrendre = medicament['nombreComprimes'] as int;
    
    if (stockActuel < nombreAPrendre) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning, color: Colors.white),
              const SizedBox(width: 8),
              Text('${_tr('home.insufficient_stock')} $stockActuel ${_tr('home.tablets_remaining')}'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
    // Supprimer l'ancienne entrée si elle existe
    prisesAujourdhui.removeWhere(
      (p) => p['medicamentId'] == medicament['id'] && p['heure'] == medicament['heure'],
    );
    
    // Ajouter la nouvelle prise
    prisesAujourdhui.add({
      'medicamentId': medicament['id'],
      'heure': medicament['heure'],
      'pris': true,
      'heurePrise': TimeOfDay.now().format(context),
      'nombreComprimes': medicament['nombreComprimes'],
    });
    
    // Décrémenter le stock dans la posologie locale
    maPosologie[index]['stock'] = stockActuel - nombreAPrendre;
  });
  
  // Sauvegarder les données
  await _savePrises();
  await _savePosologie();
  
  // NOUVELLE LIGNE À AJOUTER : Sauvegarder aussi dans SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  String stockKey = '${medicament['nom']}_${medicament['dosage']}_stock';
  await prefs.setInt(stockKey, stockActuel - nombreAPrendre);
    
    // Afficher un message de confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('${medicament['nom']} ${_tr('home.marked_as_taken')} ! ${_tr('home.stock')}: ${maPosologie[index]['stock']}'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _savePosologie() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ma_posologie', json.encode(maPosologie));
  }

  @override
  Widget build(BuildContext context) {
    // Trier les médicaments par heure
    final medicamentsTriees = List<Map<String, dynamic>>.from(maPosologie)
      ..sort((a, b) {
        final heureA = _parseHeure(a['heure']);
        final heureB = _parseHeure(b['heure']);
        final minutesA = heureA.hour * 60 + heureA.minute;
        final minutesB = heureB.hour * 60 + heureB.minute;
        return minutesA.compareTo(minutesB);
      });

int getMedicamentsPrisAujourdhui() {
  return medicamentsTriees.where((m) => _getStatutPrise(m) == StatutPrise.pris).length;
}

int getTotalMedicamentsAujourdhui() {
  return medicamentsTriees.length;
}
    return AnimatedBuilder(
      animation: _languageProvider,
      builder: (context, child) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1565C0), // Bleu très foncé
                  Color(0xFF1E88E5), // Bleu foncé
                  Colors.white,
                ],
              ),
            ),
            child: CustomScrollView(
              slivers: [
                // Thème de l'application
                SliverAppBar(
                  expandedHeight: 120,
                  floating: false,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      _tr('app.home'),
                      style: const TextStyle(
                        color: Color(0xFF2E3A59),
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF1565C0), // Bleu très foncé
                            Color(0xFF1E88E5), // Bleu foncé
                          ],
                        ),
                      ),
                      child: Container(
                        // Le dégradé de fond global :
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF81D4FA), // Bleu clair
                              Color(0xFFF8F9FA),
                              Colors.white,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Carte de bienvenue avec date/heure
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF81D4FA), // Bleu clair
                          Color(0xFFF8F9FA),
                          Colors.white,
                          ],
                        ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.wb_sunny, color: Colors.white, size: 28),
                                  const SizedBox(width: 12),
                                  Text(
                                    _tr('home.welcome'),
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _getFormattedDate(maintenant),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${getMedicamentsPrisAujourdhui()}/${getTotalMedicamentsAujourdhui()} ${_tr('home.medications_today')}',
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Section Dashboard du jour
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Icon(Icons.today, color: Color.fromARGB(255, 0, 0, 0), size: 24),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _tr('home.daily_dashboard'),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E3A59),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Liste des médicaments
                        if (medicamentsTriees.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(40),
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
                            child: Column(
                              children: [
                                Icon(
                                  Icons.medication_liquid_outlined,
                                  size: 60,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _tr('home.no_medications'),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _tr('home.configure_medications'),
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
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
                            child: Column(
                              children: medicamentsTriees.map((medicament) {
                                final statut = _getStatutPrise(medicament);
                                final couleur = _getStatutColor(statut);
                                final icone = _getStatutIcon(statut);
                                final texteStatut = _getStatutText(statut);

                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [couleur.withOpacity(0.1), Colors.white],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: couleur.withOpacity(0.3), width: 2),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    leading: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: couleur.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(color: couleur.withOpacity(0.5)),
                                      ),
                                      child: Icon(
                                        icone,
                                        color: couleur,
                                        size: 28,
                                      ),
                                    ),
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${medicament['nom']} ${medicament['dosage']}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Color(0xFF2E3A59),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: couleur,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            texteStatut,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.access_time, size: 16, color: Colors.blue[600]),
                                            const SizedBox(width: 4),
                                            Text(
                                              medicament['heure'],
                                              style: TextStyle(
                                                color: Colors.blue[600],
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Icon(Icons.medication_liquid, size: 16, color: Colors.green[600]),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${medicament['nombreComprimes']} ${_tr('home.tablets')}',
                                              style: TextStyle(
                                                color: Colors.green[600],
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (medicament['aJeun'] == true) ...[
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.no_food, size: 16, color: Colors.orange[600]),
                                              const SizedBox(width: 4),
                                              Text(
                                                _tr('home.take_on_empty_stomach'),
                                                style: TextStyle(
                                                  color: Colors.orange[600],
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  trailing: statut != StatutPrise.pris
                                  ? statut == StatutPrise.oublie && medicament['aJeun'] == true
                                      ? ElevatedButton(
                                          onPressed: () => _demarrerRattrapage(medicament),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.purple,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          ),
                                          child: Text(
                                            _tr('catch_up.button'),
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                            textAlign: TextAlign.center,
                                          ),
                                        )
                                      : statut == StatutPrise.oublie
                                          ? Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: const Icon(Icons.block, color: Colors.red, size: 24),
                                            )
                                          : ElevatedButton(
                                              onPressed: () => _marquerCommePris(medicament),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: couleur,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                              ),
                                              child: Text(
                                                _tr('home.mark_taken'),
                                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                                textAlign: TextAlign.center,
                                              ),
                                            )
                                  : Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.check, color: Colors.green, size: 24),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                        const SizedBox(height: 20),

                        // Section Stocks des médicaments
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFF9800), Color(0xFFF44336)],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Icon(Icons.inventory, color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                                _tr('home.stock'), // À traduire si nécessaire
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E3A59),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Grille des stocks
                        if (medicamentsDisponibles.isNotEmpty)
                          Container(
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
                            child: Column(
                              children: _buildAllMedicationsStockList(),
                            ),
                          ),

                        const SizedBox(height: 20),

                        // Statistiques du jour
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.grey[50]!, Colors.white],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _tr('home.daily_statistics'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E3A59),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      _tr('home.status.taken'),
                                      medicamentsTriees.where((m) => _getStatutPrise(m) == StatutPrise.pris).length,
                                      Colors.green,
                                      Icons.check_circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatCard(
                                      _tr('home.status.upcoming'),
                                      medicamentsTriees.where((m) => _getStatutPrise(m) == StatutPrise.aVenir).length,
                                      Colors.blue,
                                      Icons.schedule,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      _tr('home.status.now'),
                                      medicamentsTriees.where((m) => _getStatutPrise(m) == StatutPrise.enCours).length,
                                      Colors.orange,
                                      Icons.notifications_active,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatCard(
                                      _tr('home.status.missed'),
                                      medicamentsTriees.where((m) => _getStatutPrise(m) == StatutPrise.oublie).length,
                                      Colors.red,
                                      Icons.warning,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        

                        // Bouton Historique
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Colors.teal, Colors.cyan],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Icon(Icons.history, color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const HistoriquePage()),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                  ),
                                  child: const Text(
                                    '📊 Historique des prises',
                                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 100), // Espace pour la navigation
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Ajouter cette fonction pour récupérer le stock :
Future<int> _getStockForMedication(String nom, String dosage) async {
  final prefs = await SharedPreferences.getInstance();
  String stockKey = '${nom}_${dosage}_stock';
  return prefs.getInt(stockKey) ?? 0;
}

  List<Widget> _buildAllMedicationsStockList() {
    return medicamentsDisponibles.map((medicament) {
      // Récupérer le stock depuis SharedPreferences
      return FutureBuilder<int>(
        future: _getStockForMedication(medicament['nom'], medicament['dosage']),
        builder: (context, snapshot) {
          int stock = snapshot.data ?? 0;
          final couleurStock = _getStockColor(stock);
          
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [couleurStock.withOpacity(0.1), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: couleurStock.withOpacity(0.3)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: GestureDetector(
                onTap: () => _agrandirImage(medicament['image'], medicament['nom']),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: couleurStock.withOpacity(0.5)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      medicament['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: couleurStock.withOpacity(0.2),
                          child: Icon(Icons.medication, color: couleurStock, size: 24),
                        );
                      },
                    ),
                  ),
                ),
              ),
              title: Text(
                '${medicament['nom']} ${medicament['dosage']}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF2E3A59),
                ),
              ),
              subtitle: Row(
                children: [
                  Icon(Icons.inventory, size: 16, color: couleurStock),
                  const SizedBox(width: 4),
                  Text(
                    '${_tr('home.stock')}: $stock ${_tr('home.tablets')}',
                    style: TextStyle(
                      color: couleurStock,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: couleurStock,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$stock',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          );
        },
      );
    }).toList();
  }
  Color _getStockColor(int stock) {
    if (stock > 15) return Colors.green;
    if (stock > 5) return Colors.orange;
    return Colors.red;
  }

  Widget _buildStatCard(String titre, int nombre, Color couleur, IconData icone) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: couleur.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: couleur.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icone, color: couleur, size: 24),
          const SizedBox(height: 8),
          Text(
            nombre.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: couleur,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            titre,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: couleur.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getFormattedDate(DateTime date) {
    final jours = [
      _tr('date.monday'), 
      _tr('date.tuesday'), 
      _tr('date.wednesday'), 
      _tr('date.thursday'), 
      _tr('date.friday'), 
      _tr('date.saturday'), 
      _tr('date.sunday')
    ];
    final mois = [
      _tr('date.january'), _tr('date.february'), _tr('date.march'), 
      _tr('date.april'), _tr('date.may'), _tr('date.june'),
      _tr('date.july'), _tr('date.august'), _tr('date.september'), 
      _tr('date.october'), _tr('date.november'), _tr('date.december')
    ];
    
    final jourSemaine = jours[date.weekday - 1];
    final jour = date.day;
    final moisNom = mois[date.month - 1];
    final annee = date.year;
    
    return '$jourSemaine $jour $moisNom $annee';
  }
}

enum StatutPrise {
  pris,
  aVenir,
  enCours,
  oublie,
}