// ===== lib/pages/medicaments_page.dart =====
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../providers/language_provider.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'pdf_viewer_page.dart';
import 'package:flutter/foundation.dart';
import '../services/notification_service.dart';

class MedicamentsPage extends StatefulWidget {
  const MedicamentsPage({super.key});

  @override
  MedicamentsPageState createState() => MedicamentsPageState();
}

class MedicamentsPageState extends State<MedicamentsPage> with WidgetsBindingObserver {
  final LanguageProvider _languageProvider = LanguageProvider();
  

  String _tr(String key) {
    return _languageProvider.translate(key);
  }
  int _generateSafeId() {
  // Utiliser les secondes depuis epoch + un nombre aléatoire
  final now = DateTime.now();
  final seconds = now.millisecondsSinceEpoch ~/ 1000; // Diviser par 1000
  final random = (seconds % 100000); // Garder seulement les 5 derniers chiffres
  return random;
}

  List<Map<String, dynamic>> medicamentsDisponibles = [
    {
      'nom': 'Rifadine',
      'dosage': '300mg',
      'image': 'assets/medics/RIFADINE 300 mg.jpg',
      'descriptionKey': 'medications.drugs.rifadine.description',
      'effetsSecondairesKey': 'medications.drugs.rifadine.side_effects',
      'conseilsKey': 'medications.drugs.rifadine.advice',
      'pdf': 'assets/pdf/RIFADINE 300 mg.pdf'
    },
    {
      'nom': 'Rifater',
      'dosage': '120mg/50mg/300mg',
      'image': 'assets/medics/RIFATER.jpg',
      'descriptionKey': 'medications.drugs.rifater.description',
      'effetsSecondairesKey': 'medications.drugs.rifater.side_effects',
      'conseilsKey': 'medications.drugs.rifater.advice',
      'pdf': 'assets/pdf/RIFATER.pdf'
    },
    {
      'nom': 'Rifinah',
      'dosage': '300mg/150mg',
      'image': 'assets/medics/RIFINAH.jpg',
      'descriptionKey': 'medications.drugs.rifinah.description',
      'effetsSecondairesKey': 'medications.drugs.rifinah.side_effects',
      'conseilsKey': 'medications.drugs.rifinah.advice',
      'pdf': 'assets/pdf/RIFINAH.pdf'
    },
    {
      'nom': 'Dexambutol',
      'dosage': '500mg',
      'image': 'assets/medics/DEXAMBUTOL 500 mg.jpg',
      'descriptionKey': 'medications.drugs.dexambutol.description',
      'effetsSecondairesKey': 'medications.drugs.dexambutol.side_effects',
      'conseilsKey': 'medications.drugs.dexambutol.advice',
      'pdf': 'assets/pdf/DEXAMBUTOL 500 mg.pdf'
    },
    {
      'nom': 'Myambutol',
      'dosage': '400mg',
      'image': 'assets/medics/MYAMBUTOL 400 mg.jpg',
      'descriptionKey': 'medications.drugs.myambutol.description',
      'effetsSecondairesKey': 'medications.drugs.myambutol.side_effects',
      'conseilsKey': 'medications.drugs.myambutol.advice',
      'pdf': 'assets/pdf/MYAMBUTOL 400 mg.pdf'
    },
    {
      'nom': 'Pirilène',
      'dosage': '500mg',
      'image': 'assets/medics/PIRILENE 500 mg.jpg',
      'descriptionKey': 'medications.drugs.pirilene.description',
      'effetsSecondairesKey': 'medications.drugs.pirilene.side_effects',
      'conseilsKey': 'medications.drugs.pirilene.advice',
      'pdf': 'assets/pdf/PIRILENE 500 mg.pdf'
    },
    {
      'nom': 'Rimactan',
      'dosage': '300mg',
      'image': 'assets/medics/RIMACTAN 300 mg.jpg',
      'descriptionKey': 'medications.drugs.rimactan.description',
      'effetsSecondairesKey': 'medications.drugs.rimactan.side_effects',
      'conseilsKey': 'medications.drugs.rimactan.advice',
      'pdf': 'assets/pdf/RIMACTAN 300 mg.pdf'
    },
    {
      'nom': 'Rimifon',
      'dosage': '50mg',
      'image': 'assets/medics/RIMIFON 50 mg.jpg',
      'descriptionKey': 'medications.drugs.rimifon.description',
      'effetsSecondairesKey': 'medications.drugs.rimifon.side_effects',
      'conseilsKey': 'medications.drugs.rimifon.advice',
      'pdf': 'assets/pdf/RIMIFON 50 mg.pdf'
    },
    {
      'nom': 'Rimifon',
      'dosage': '150mg',
      'image': 'assets/medics/RIMIFON 150 mg.jpg',
      'descriptionKey': 'medications.drugs.rimifon.description',
      'effetsSecondairesKey': 'medications.drugs.rimifon.side_effects',
      'conseilsKey': 'medications.drugs.rimifon.advice',
      'pdf': 'assets/pdf/RIMIFON 150 mg.pdf'
    },
  ];

  List<Map<String, dynamic>> maPosologie = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPosologie();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadPosologie();
    }
  }

  void refreshPosologie() {
    _loadPosologie();
  }

  // Fonction pour récupérer le stock d'un médicament
  Future<int> _getStockForMedication(String nom, String dosage) async {
    final prefs = await SharedPreferences.getInstance();
    String stockKey = '${nom}_${dosage}_stock';
    return prefs.getInt(stockKey) ?? 0;
  }

  void _gererStock(Map<String, dynamic> medicament) async {
    final prefs = await SharedPreferences.getInstance();
    String stockKey = '${medicament['nom']}_${medicament['dosage']}_stock';
    int currentStock = prefs.getInt(stockKey) ?? 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        int newStock = currentStock;
        
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange[400]!, Colors.orange[600]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.inventory, color: Colors.white, size: 30),
                    const SizedBox(height: 8),
                    Text(
                    _tr('medications.stock_management.title'),
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    ),
                    Text(
                      '${medicament['nom']} ${medicament['dosage']}',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_tr('medications.stock_management.current_stock'), style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (newStock > 0) {
                            setDialogState(() => newStock--);
                          }
                        },
                        icon: const Icon(Icons.remove_circle, color: Colors.red, size: 40),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.orange[300]!),
                        ),
                        child: Text(
                          '$newStock',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setDialogState(() => newStock++);
                        },
                        icon: const Icon(Icons.add_circle, color: Colors.green, size: 40),
                      ),
                    ],
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
                    await prefs.setInt(stockKey, newStock);
                    // Mettre à jour aussi dans la posologie si le médicament y est
                    bool updated = false;
                    for (int i = 0; i < maPosologie.length; i++) {
                      if (maPosologie[i]['nom'] == medicament['nom'] && 
                          maPosologie[i]['dosage'] == medicament['dosage']) {
                        setState(() {
                          maPosologie[i]['stock'] = newStock;
                        });
                        updated = true;
                      }
                    }
                    if (updated) {
                      await _savePosologie();
                    }
                    
                    Navigator.pop(context);
                    setState(() {}); // Rafraîchir l'affichage
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_tr('messages.stock_updated').replaceAll('{stock}', '$newStock')),
                        backgroundColor: Colors.orange[600],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[600],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                child: Text(_tr('medications.stock_management.confirm'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _loadPosologie() async {
    final prefs = await SharedPreferences.getInstance();
    final String? posologieJson = prefs.getString('ma_posologie');
    if (posologieJson != null && mounted) {
      setState(() {
        maPosologie = List<Map<String, dynamic>>.from(json.decode(posologieJson));
      });
      
      await _synchroniserStocks();
    }
  }

  Future<void> _scheduleNotificationForMedication(Map<String, dynamic> medication) async {
    try {
      final time = medication['heure'].split(':');
      final hour = int.parse(time[0]);
      final minute = int.parse(time[1]);
      final aJeun = medication['aJeun'] ?? false;
      final now = DateTime.now();
      
      // Pour aujourd'hui
      DateTime scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
      
      // Si l'heure est déjà passée aujourd'hui, programmer pour demain
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }
      
      final baseId = medication['id'];
      
      // 1. Notification de jeûne (2h avant, seulement si à jeun)
      if (aJeun) {
        DateTime fastingTime = scheduledTime.subtract(const Duration(hours: 2));
        if (fastingTime.isAfter(now)) {
          await NotificationService.showFastingReminder(
            baseId: baseId,
            medicamentNom: medication['nom'],
            dosage: medication['dosage'],
            scheduledTime: scheduledTime,
          );
        }
      }
      
      // 2. Notification 5 minutes avant
      DateTime fiveMinBefore = scheduledTime.subtract(const Duration(minutes: 5));
      if (fiveMinBefore.isAfter(now)) {
        await NotificationService.show5MinReminder(
          baseId: baseId,
          medicamentNom: medication['nom'],
          dosage: medication['dosage'],
          nombreComprimes: medication['nombreComprimes'],
          aJeun: aJeun,
          scheduledTime: scheduledTime,
        );
      }
      
      // 3. Notification à l'heure exacte
      if (scheduledTime.isAfter(now)) {
        await NotificationService.showTimeReminder(
          baseId: baseId,
          medicamentNom: medication['nom'],
          dosage: medication['dosage'],
          nombreComprimes: medication['nombreComprimes'],
          aJeun: aJeun,
          scheduledTime: scheduledTime,
        );
      }
      
      // Message de confirmation
      String confirmMsg = _tr('messages.notifications_scheduled')
        .replaceAll('{medication}', medication['nom'])
        .replaceAll('{time}', medication['heure']);
      if (aJeun && scheduledTime.subtract(const Duration(hours: 2)).isAfter(now)) {
        confirmMsg += _tr('messages.notifications_scheduled_fasting');
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(confirmMsg),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_tr('messages.notifications_error').replaceAll('{error}', '$e')),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }  Future<void> _synchroniserStocks() async {
    final prefs = await SharedPreferences.getInstance();
    bool stocksModifies = false;
    
    for (int i = 0; i < maPosologie.length; i++) {
      String stockKey = '${maPosologie[i]['nom']}_${maPosologie[i]['dosage']}_stock';
      int stockSauvegarde = prefs.getInt(stockKey) ?? maPosologie[i]['stock'];
      
      if (maPosologie[i]['stock'] != stockSauvegarde) {
        maPosologie[i]['stock'] = stockSauvegarde;
        stocksModifies = true;
      }
    }
    
    if (stocksModifies && mounted) {
      setState(() {});
      await _savePosologie();
    }
  }

  Future<void> _savePosologie() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ma_posologie', json.encode(maPosologie));
  }
  
  Future<void> _telechargerPdf(String cheminPdf, String nomMedicament) async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_tr('medications.pdf.download_web_only')),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      PermissionStatus storageStatus;
      if (Platform.isAndroid) {
        storageStatus = await Permission.storage.status;
        if (storageStatus.isDenied) {
          storageStatus = await Permission.storage.request();
        }
        
        if (storageStatus.isDenied) {
          storageStatus = await Permission.manageExternalStorage.request();
        }
        
        if (storageStatus.isDenied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_tr('medications.pdf.storage_permission')),
              backgroundColor: Colors.orange,
              action: SnackBarAction(
                label: 'Paramètres',
                onPressed: () => openAppSettings(),
              ),
            ),
          );
          return;
        }
      }

      final ByteData bytes = await DefaultAssetBundle.of(context).load(cheminPdf);
      final Uint8List list = bytes.buffer.asUint8List();
      
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
      } else if (Platform.isIOS) {
        downloadsDir = await getApplicationDocumentsDirectory();
      }
      
      if (downloadsDir != null && await downloadsDir.exists()) {
        final String fileName = '${nomMedicament.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final File file = File('${downloadsDir.path}/$fileName');
        
        await file.writeAsBytes(list);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('${_tr('medications.pdf.downloaded')}: $fileName')),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_tr('medications.pdf.download_error')}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getStockColor(int stock) {
    if (stock > 15) return Colors.green;
    if (stock > 5) return Colors.orange;
    return Colors.red;
  }

  String _formatTime(TimeOfDay time, bool use24h) {
    if (use24h) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
      final period = time.period == DayPeriod.am ? 'AM' : 'PM';
      return '${hour.toString()}:${time.minute.toString().padLeft(2, '0')} $period';
    }
  }

  void _ajouterMedicament(Map<String, dynamic> medicament) async {
    Map<String, dynamic>? medicamentExistant;
    try {
      medicamentExistant = maPosologie.firstWhere(
        (m) => m['nom'] == medicament['nom'] && m['dosage'] == medicament['dosage'],
      );
    } catch (e) {
      medicamentExistant = null;
    }

    final prefs = await SharedPreferences.getInstance();
    String stockKey = '${medicament['nom']}_${medicament['dosage']}_stock';
    int stockInitial = prefs.getInt(stockKey) ?? (medicamentExistant != null ? medicamentExistant['stock'] : 30);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        TimeOfDay heureSelectionnee = TimeOfDay.now();
        int nombreComprimes = 1;
        bool aJeun = false;
        int stock = stockInitial;
        bool formatDialog24h = true;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
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
                      '${_tr('medications.add_dialog_title')} ${medicament['nom']}',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Format d'heure
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.indigo[50]!, Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.indigo[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, color: Colors.indigo[600]),
                            const SizedBox(width: 12),
                            Text(
                              _tr('medications.time_format'),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: formatDialog24h ? Colors.indigo[100] : Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '24h',
                                style: TextStyle(
                                  color: formatDialog24h ? Colors.indigo[700] : Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Switch(
                              value: !formatDialog24h,
                              onChanged: (value) {
                                setDialogState(() {
                                  formatDialog24h = !value;
                                });
                              },
                              activeColor: Colors.indigo[600],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: !formatDialog24h ? Colors.indigo[100] : Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '12h',
                                style: TextStyle(
                                  color: !formatDialog24h ? Colors.indigo[700] : Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Heure de prise
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue[50]!, Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, color: Colors.blue[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${_tr('medications.time_label')}: ${_formatTime(heureSelectionnee, formatDialog24h)}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final TimeOfDay? nouvelleHeure = await showTimePicker(
                                  context: context,
                                  initialTime: heureSelectionnee,
                                  builder: (BuildContext context, Widget? child) {
                                    return MediaQuery(
                                      data: MediaQuery.of(context).copyWith(
                                        alwaysUse24HourFormat: formatDialog24h,
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                
                                if (nouvelleHeure != null) {
                                  setDialogState(() {
                                    heureSelectionnee = nouvelleHeure;
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(_tr('medications.change'), style: const TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),

                      // Nombre de comprimés
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green[50]!, Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.medication_liquid, color: Colors.green[700]),
                            const SizedBox(width: 12),
                            Text(_tr('medications.tablets_count'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                if (nombreComprimes > 1) {
                                  setDialogState(() => nombreComprimes--);
                                }
                              },
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Text('$nombreComprimes', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                            IconButton(
                              onPressed: () {
                                setDialogState(() => nombreComprimes++);
                              },
                              icon: const Icon(Icons.add_circle, color: Colors.green),
                            ),
                          ],
                        ),
                      ),

                      // Stock
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.purple[50]!, Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.purple[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.inventory, color: Colors.purple[700]),
                            const SizedBox(width: 12),
                            Text('${_tr('medications.stock')}:', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                if (stock > 0) {
                                  setDialogState(() => stock--);
                                }
                              },
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: _getStockColor(stock),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text('$stock', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                            IconButton(
                              onPressed: () {
                                setDialogState(() => stock++);
                              },
                              icon: const Icon(Icons.add_circle, color: Colors.green),
                            ),
                          ],
                        ),
                      ),

                      // À jeun
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.orange[50]!, Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.no_food, color: Colors.orange[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(_tr('medications.take_fasting'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                            ),
                            Switch(
                              value: aJeun,
                              onChanged: (value) {
                                setDialogState(() => aJeun = value);
                              },
                              activeColor: Colors.orange[600],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(_tr('common.cancel'), style: TextStyle(color: Colors.grey[600])),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      final newMedication = {
                        'id': _generateSafeId(),
                        'nom': medicament['nom'],
                        'dosage': medicament['dosage'],
                        'heure': '${heureSelectionnee.hour.toString().padLeft(2, '0')}:${heureSelectionnee.minute.toString().padLeft(2, '0')}',
                        'nombreComprimes': nombreComprimes,
                        'aJeun': aJeun,
                        'stock': stock,
                        'image': medicament['image'],
                      };
                      maPosologie.add(newMedication);
                      
                      _scheduleNotificationForMedication(newMedication);
                    });
                    _savePosologie();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(_tr('medications.add_button'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _supprimerMedicament(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red[400]!, Colors.red[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                const Icon(Icons.delete_forever, color: Colors.white, size: 30),
                const SizedBox(height: 8),
                Text(
                  _tr('medications.delete_confirmation'),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          content: Text(
            _tr('medications.delete_question'),
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(_tr('common.cancel'), style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () async {
                // DEBUG: Afficher l'ID à supprimer
                print('🗑️ Tentative de suppression du médicament avec ID: $id');
                print('📋 Liste actuelle: ${maPosologie.map((m) => '${m['nom']} (ID: ${m['id']})').toList()}');
                
                // Annuler les notifications
                try {
                  for (int day = 0; day < 30; day++) {
                    final baseId = id + (day * 10000);
                    await NotificationService.cancelMedicationNotifications(baseId);
                  }
                } catch (e) {
                  print('⚠️ Erreur lors de l\'annulation des notifications: $e');
                }
                
                // Supprimer de la liste
                final initialLength = maPosologie.length;
                setState(() {
                  maPosologie.removeWhere((med) => med['id'] == id);
                });
                
                // Vérifier si la suppression a fonctionné
                final newLength = maPosologie.length;
                
                if (newLength < initialLength) {
                  // Sauvegarder immédiatement
                  await _savePosologie();
                  
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                    content: Text(_tr('messages.medication_deleted_success')),
                      backgroundColor: Colors.green[600],
                    ),
                  );
                } else {
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                    content: Text(_tr('messages.medication_not_found')),
                      backgroundColor: Colors.red[600],
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            child: Text(_tr('medications.delete'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
  void _voirDetailsMedicament(Map<String, dynamic> medicament) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _agrandirImage(medicament['image'], medicament['nom']),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        medicament['image'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.medication, color: Color(0xFF6C63FF), size: 40);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(_tr('medications.details.enlarge_hint'),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  medicament['nom'],
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text(
                  medicament['dosage'],
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Text(_tr('medications.details.description'),
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue[700]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(_tr(medicament['descriptionKey']), style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  
                  // Effets secondaires
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning, color: Colors.orange[700]),
                            const SizedBox(width: 8),
                            Text(_tr('medications.details.side_effects'),
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange[700]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(_tr(medicament['effetsSecondairesKey']), style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  
                  // Conseils
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb, color: Colors.green[700]),
                            const SizedBox(width: 8),
                            Text(_tr('medications.details.advice'),
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green[700]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(_tr(medicament['conseilsKey']), style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  
                  // Bouton pour ouvrir le document
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _ouvrirDocumentPdf(medicament['pdf'], medicament['nom']);
                      },
                      icon: const Icon(Icons.description, color: Colors.white),
                      label: Text(_tr('medications.details.see_documentation'), style: const TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[600],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:Text(_tr('medications.details.close'), style: TextStyle(color: Colors.grey[600])),
            ),
          ],
        );
      },
    );
  }

  // Nouvelle fonction pour agrandir l'image
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
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    size: 80,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(_tr('medications.image.not_available'),
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.touch_app, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(_tr('medications.image.tap_to_close'),
                          style: const TextStyle(
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

  void _ouvrirDocumentPdf(String cheminPdf, String nomMedicament) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red[400]!, Colors.red[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                const Icon(Icons.picture_as_pdf, color: Colors.white, size: 30),
                const SizedBox(height: 8),
                Text(_tr('medications.pdf.documentation_title'),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text(
                  nomMedicament,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.picture_as_pdf, size: 60, color: Colors.red[600]),
                      const SizedBox(height: 16),
                      Text(_tr('medications.pdf.document_available'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('${_tr('medications.pdf.file')}: ${cheminPdf.split('/').last}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _visualiserPdf(cheminPdf, nomMedicament);
                        },
                        icon: const Icon(Icons.visibility, color: Colors.white),
                        label: Text(_tr('medications.pdf.view'), style: const TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _telechargerPdf(cheminPdf, nomMedicament);
                        },
                        icon: const Icon(Icons.download, color: Colors.white),
                        label: Text(_tr('medications.pdf.download'), style: const TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(_tr('medications.details.close'), style: TextStyle(color: Colors.grey[600])),
            ),
          ],
        );
      },
    );
  }

  void _visualiserPdf(String cheminPdf, String nomMedicament) async {
    try {
      if (kIsWeb) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerPage(
              assetPath: cheminPdf,
              title: nomMedicament,
              isAsset: true,
            ),
          ),
        );
      } else {
        final ByteData bytes = await DefaultAssetBundle.of(context).load(cheminPdf);
        final Uint8List list = bytes.buffer.asUint8List();
        
        final Directory tempDir = await getTemporaryDirectory();
        final File file = File('${tempDir.path}/${nomMedicament.replaceAll(' ', '_')}.pdf');
        
        await file.writeAsBytes(list);
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerPage(
              filePath: file.path,
              title: nomMedicament,
              isAsset: false,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_tr('medications.pdf.view_error')}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  Color(0xFFE3F2FD),
                  Color(0xFFF8F9FA),
                  Colors.white,
                ],
              ),
            ),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 120,
                  floating: false,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      _tr('app.medications'),
                      style: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
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
                            Color(0xFF1565C0),
                            Color(0xFF1E88E5),
                          ],
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
                        // Section Médicaments disponibles
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color.fromARGB(255, 120, 235, 255), Color.fromARGB(255, 159, 236, 255)],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Icon(Icons.local_pharmacy, color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _tr('medications.available_title'),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E3A59),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Liste des médicaments disponibles avec stock
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
                            children: medicamentsDisponibles.map((medicament) {
                              return FutureBuilder<int>(
                                future: _getStockForMedication(medicament['nom'], medicament['dosage']),
                                builder: (context, snapshot) {
                                  int stock = snapshot.data ?? 0;
                                  
                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.grey[50]!, Colors.white],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(color: Colors.grey[200]!, width: 1),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(16),
                                      onTap: () => _voirDetailsMedicament(medicament),
                                      leading: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [const Color(0xFF6C63FF).withOpacity(0.1), const Color(0xFF4CAF50).withOpacity(0.1)],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
                                        ),
                                        child: const Icon(
                                          Icons.medication,
                                          color: Color(0xFF6C63FF),
                                          size: 24,
                                        ),
                                      ),
                                      title: Text(
                                        medicament['nom'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF2E3A59),
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            medicament['dosage'],
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          // Affichage du stock
                                          Row(
                                            children: [
                                              Icon(Icons.inventory, size: 16, color: _getStockColor(stock)),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${_tr('medications.stock')}: $stock',
                                                style: TextStyle(
                                                  color: _getStockColor(stock),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _tr(medicament['descriptionKey']),
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 12,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () => _gererStock(medicament),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange[600],
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            ),
                                            child: Text(
                                              _tr('medications.stock'),
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            onPressed: () => _ajouterMedicament(medicament),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF6C63FF),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            ),
                                            child: Text(
                                              _tr('medications.add_button'),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Section Ma posologie - Code corrigé
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color.fromARGB(255, 120, 235, 255), Color.fromARGB(255, 159, 236, 255)],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Icon(Icons.schedule, color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _tr('medications.my_posology'),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E3A59),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Liste de la posologie avec seulement le bouton supprimer
                        if (maPosologie.isEmpty)
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
                                  _tr('medications.no_medication'),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
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
                              children: maPosologie.map((medicament) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [const Color(0xFF4CAF50).withOpacity(0.1), Colors.white],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    leading: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [const Color(0xFF4CAF50).withOpacity(0.2), const Color(0xFF4CAF50).withOpacity(0.1)],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.5)),
                                      ),
                                      child: const Icon(
                                        Icons.medication,
                                        color: Color(0xFF4CAF50),
                                        size: 24,
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
                                        if (medicament['aJeun'] == true)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.orange[100],
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: Colors.orange[300]!),
                                            ),
                                            child: Text(
                                              _tr('medications.fasting'),
                                              style: TextStyle(
                                                color: Colors.orange[700],
                                                fontSize: 10,
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
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Icon(Icons.medication_liquid, size: 16, color: Colors.green[600]),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${medicament['nombreComprimes']} ${_tr('medications.tablets')}',
                                              style: TextStyle(
                                                color: Colors.green[600],
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.inventory, size: 16, color: _getStockColor(medicament['stock'])),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${_tr('medications.stock')}: ${medicament['stock']}',
                                              style: TextStyle(
                                                color: _getStockColor(medicament['stock']),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    // SEULEMENT le bouton supprimer
                                    trailing: ElevatedButton(
                                      onPressed: () => _supprimerMedicament(medicament['id']),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red[600],
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      ),
                                      child: Text(
                                        _tr('medications.delete'),
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
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
}