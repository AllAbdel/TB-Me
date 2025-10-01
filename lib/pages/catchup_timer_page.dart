// /lib/pages/catchup_timer_page.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../providers/language_provider.dart';
import '../services/catchup_service.dart' as catchup_service;
import '../services/notification_service.dart';

class CatchupTimerPage extends StatefulWidget {
  final Map<String, dynamic> medicament;
  final bool isAlreadyFasting;

  const CatchupTimerPage({
    super.key,
    required this.medicament,
    this.isAlreadyFasting = false,
  });

  @override
  _CatchupTimerPageState createState() => _CatchupTimerPageState();
}

class _CatchupTimerPageState extends State<CatchupTimerPage> with WidgetsBindingObserver {
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
    WidgetsBinding.instance.addObserver(this);
    _loadCatchupData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Recharger les données quand on revient sur l'app
      _loadCatchupData();
    }
  }

  Future<void> _loadCatchupData() async {
    if (widget.isAlreadyFasting) {
      await catchup_service.CatchupService.removeCatchup(widget.medicament['id']);
      setState(() {
        _isCompleted = true;
        _remainingTime = Duration.zero;
      });
      return;
    }

    final catchups = await catchup_service.CatchupService.getActiveCatchups();
    final existingCatchup = catchups.firstWhere(
      (c) => c['medicationId'] == widget.medicament['id'],
      orElse: () => <String, dynamic>{},
    );

    if (existingCatchup.isNotEmpty) {
      _endTime = DateTime.fromMillisecondsSinceEpoch(existingCatchup['endTime']);
      _calculateRemainingTime();
      _startTimer();
    } else {
      _endTime = DateTime.now().add(const Duration(hours: 2));
      await _programmerNotificationRattrapage();
      _startTimer();
    }
  }

  Future<void> _programmerNotificationRattrapage() async {
    if (_endTime != null) {
      await NotificationService.showCatchupComplete(
        baseId: widget.medicament['id'],
        medicamentNom: widget.medicament['nom'],
        dosage: widget.medicament['dosage'],
        scheduledTime: _endTime!,
      );
    }
  }

  void _calculateRemainingTime() {
    final now = DateTime.now();
    if (_endTime!.isBefore(now)) {
      setState(() {
        _isCompleted = true;
        _remainingTime = Duration.zero;
      });
      _timer?.cancel();
    } else {
      setState(() {
        _remainingTime = _endTime!.difference(now);
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

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> _prendreLeMaticament() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Charger la posologie
    final String? posologieJson = prefs.getString('ma_posologie');
    if (posologieJson == null) {
      print('❌ Erreur: Posologie introuvable');
      return;
    }
    
    List<Map<String, dynamic>> maPosologie = List<Map<String, dynamic>>.from(json.decode(posologieJson));
    
    // Trouver l'index du médicament
    final index = maPosologie.indexWhere((m) => m['id'] == widget.medicament['id']);
    if (index == -1) {
      print('❌ Erreur: Médicament introuvable dans la posologie');
      return;
    }
    
    final stockActuel = maPosologie[index]['stock'] as int;
    final nombreAPrendre = widget.medicament['nombreComprimes'] as int;
    
    print('📦 Stock actuel: $stockActuel, À prendre: $nombreAPrendre');
    
    if (stockActuel < nombreAPrendre) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning, color: Colors.white),
              const SizedBox(width: 8),
              Text('Stock insuffisant: $stockActuel comprimés restants'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    // Charger les prises d'aujourd'hui
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final String? prisesJson = prefs.getString('prises_$dateKey');
    List<Map<String, dynamic>> prisesAujourdhui = prisesJson != null 
        ? List<Map<String, dynamic>>.from(json.decode(prisesJson))
        : [];
    
    print('📋 Prises avant: ${prisesAujourdhui.length}');
    
    // Supprimer l'ancienne prise si elle existe
    prisesAujourdhui.removeWhere(
      (p) => p['medicamentId'] == widget.medicament['id'] && p['heure'] == widget.medicament['heure'],
    );
    
    // Ajouter la nouvelle prise
    final heurePrise = TimeOfDay.now();
    prisesAujourdhui.add({
      'medicamentId': widget.medicament['id'],
      'heure': widget.medicament['heure'],
      'pris': true,
      'heurePrise': '${heurePrise.hour.toString().padLeft(2, '0')}:${heurePrise.minute.toString().padLeft(2, '0')}',
      'nombreComprimes': widget.medicament['nombreComprimes'],
      'rattrapage': true,
    });
    
    print('📋 Prises après: ${prisesAujourdhui.length}');
    
    // Mettre à jour le stock
    final nouveauStock = stockActuel - nombreAPrendre;
    maPosologie[index]['stock'] = nouveauStock;
    
    print('📦 Nouveau stock: $nouveauStock');
    
    // Sauvegarder
    await prefs.setString('prises_$dateKey', json.encode(prisesAujourdhui));
    await prefs.setString('ma_posologie', json.encode(maPosologie));
    
    String stockKey = '${widget.medicament['nom']}_${widget.medicament['dosage']}_stock';
    await prefs.setInt(stockKey, nouveauStock);
    
    print('✅ Données sauvegardées');
    
    // Supprimer le rattrapage
    await catchup_service.CatchupService.removeCatchup(widget.medicament['id']);
    
    print('✅ Rattrapage supprimé');
    
    // Fermer la page et retourner à l'accueil
    if (mounted) {
      Navigator.of(context).pop();
      
      // Message d'encouragement
      final encouragements = _languageProvider.getEncouragementList('encouragement.missed_recovery');
      final message = catchup_service.CatchupService.getRandomEncouragement(encouragements);
      
      // Afficher le message de succès
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) {
              Future.delayed(const Duration(seconds: 30), () {
                if (Navigator.of(dialogContext).canPop()) {
                  Navigator.of(dialogContext).pop();
                }
              });
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: Row(
                  children: [
                    Icon(Icons.celebration, color: Colors.green[600]),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Bravo !',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                content: Text(message),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(_tr('common.close')),
                  ),
                ],
              );
            },
          );
        }
      });
    }
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
                    onPressed: _prendreLeMaticament,
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
                    await catchup_service.CatchupService.removeCatchup(widget.medicament['id']);
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