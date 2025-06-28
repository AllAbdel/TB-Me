// ===== lib/pages/medicaments_page.dart =====
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MedicamentsPage extends StatefulWidget {
  const MedicamentsPage({super.key});

  @override
  _MedicamentsPageState createState() => _MedicamentsPageState();
}

class _MedicamentsPageState extends State<MedicamentsPage> with WidgetsBindingObserver {
  List<Map<String, dynamic>> medicamentsDisponibles = [
    {
      'nom': 'Rifadine',
      'dosage': '300mg',
      'image': 'assets/medics/RIFADINE 300 mg.jpg',
      'description': 'Antibiotique antituberculeux de première ligne',
      'effetsSecondaires': 'Urine orangée, nausées, troubles hépatiques',
      'conseils': 'À prendre à jeun, 1h avant ou 2h après le repas',
      'docx': 'assets/docx/RIFADINE 300 mg.docx'
    },
    {
      'nom': 'Rifater',
      'dosage': '120mg/50mg/300mg',
      'image': 'assets/medics/RIFATER.jpg',
      'description': 'Combinaison fixe de rifampicine, isoniazide et pyrazinamide',
      'effetsSecondaires': 'Troubles digestifs, maux de tête, fatigue',
      'conseils': 'Combinaison de 3 médicaments en 1 comprimé',
      'docx': 'assets/docx/RIFATER.docx'
    },
    {
      'nom': 'Rifinah',
      'dosage': '300mg/150mg',
      'image': 'assets/medics/RIFINAH.jpg',
      'description': 'Association rifampicine et isoniazide',
      'effetsSecondaires': 'Coloration orange des urines, nausées',
      'conseils': 'À prendre le matin à jeun de préférence',
      'docx': 'assets/docx/RIFINAH.docx'
    },
    {
      'nom': 'Dexambutol',
      'dosage': '500mg',
      'image': 'assets/medics/DEXAMBUTOL 500 mg.jpg',
      'description': 'Antituberculeux de seconde ligne',
      'effetsSecondaires': 'Troubles visuels, neuropathie optique',
      'conseils': 'Surveillance ophtalmologique nécessaire',
      'docx': 'assets/docx/DEXAMBUTOL 500 mg.docx'
    },
    {
      'nom': 'Myambutol',
      'dosage': '400mg',
      'image': 'assets/medics/MYAMBUTOL 400 mg.jpg',
      'description': 'Éthambutol, antituberculeux bactériostatique',
      'effetsSecondaires': 'Névrite optique, troubles de la vision',
      'conseils': 'Contrôle de la vision recommandé',
      'docx': 'assets/docx/MYAMBUTOL 400 mg.docx'
    },
    {
      'nom': 'Pirilène',
      'dosage': '500mg',
      'image': 'assets/medics/PIRILENE 500 mg.jpg',
      'description': 'Pyrazinamide, antituberculeux',
      'effetsSecondaires': 'Troubles hépatiques, arthralgies',
      'conseils': 'Surveillance hépatique nécessaire',
      'docx': 'assets/docx/PIRILENE 500 mg.docx'
    },
    {
      'nom': 'Rimactan',
      'dosage': '300mg',
      'image': 'assets/medics/RIMACTAN 300 mg.jpg',
      'description': 'Rifampicine, antibiotique antituberculeux',
      'effetsSecondaires': 'Coloration orange des sécrétions',
      'conseils': 'À prendre à distance des repas',
      'docx': 'assets/docx/RIMACTAN 300 mg.docx'
    },
    {
      'nom': 'Rimifon',
      'dosage': '50mg',
      'image': 'assets/medics/RIMIFON 50 mg.jpg',
      'description': 'Isoniazide, antituberculeux majeur',
      'effetsSecondaires': 'Neuropathie périphérique, hépatite',
      'conseils': 'Supplément en vitamine B6 recommandé',
      'docx': 'assets/docx/RIMIFON 50 mg.docx'
    },
    {
      'nom': 'Rimifon',
      'dosage': '150mg',
      'image': 'assets/medics/RIMIFON 150 mg.jpg',
      'description': 'Isoniazide, antituberculeux majeur',
      'effetsSecondaires': 'Neuropathie périphérique, hépatite',
      'conseils': 'Supplément en vitamine B6 recommandé',
      'docx': 'assets/docx/RIMIFON 150 mg.docx'
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

  Future<void> _loadPosologie() async {
    final prefs = await SharedPreferences.getInstance();
    final String? posologieJson = prefs.getString('ma_posologie');
    if (posologieJson != null && mounted) {
      setState(() {
        maPosologie = List<Map<String, dynamic>>.from(json.decode(posologieJson));
      });
    }
  }

  Future<void> _savePosologie() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ma_posologie', json.encode(maPosologie));
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

  void _ajouterMedicament(Map<String, dynamic> medicament) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TimeOfDay heureSelectionnee = TimeOfDay.now();
        int nombreComprimes = 1;
        bool aJeun = false;
        
        // Chercher si ce médicament existe déjà dans la posologie
        Map<String, dynamic>? medicamentExistant;
        try {
          medicamentExistant = maPosologie.firstWhere(
            (m) => m['nom'] == medicament['nom'] && m['dosage'] == medicament['dosage'],
          );
        } catch (e) {
          medicamentExistant = null;
        }
        
        // Si il existe, prendre son stock actuel, sinon 30 par défaut
        int stock = medicamentExistant != null ? medicamentExistant['stock'] : 30;
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
                      'Ajouter ${medicament['nom']}',
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
                            const Text(
                              'Format d\'heure',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                                'Heure: ${_formatTime(heureSelectionnee, formatDialog24h)}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final TimeOfDay? picked = await showTimePicker(
                                  context: context,
                                  initialTime: heureSelectionnee,
                                  builder: (BuildContext context, Widget? child) {
                                    return MediaQuery(
                                      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: formatDialog24h),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) {
                                  setDialogState(() {
                                    heureSelectionnee = picked;
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Changer', style: TextStyle(color: Colors.white)),
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
                            const Text('Comprimés:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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
                            const Text('Stock:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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
                            const Expanded(
                              child: Text('À prendre à jeun', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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
                  child: Text('Annuler', style: TextStyle(color: Colors.grey[600])),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      maPosologie.add({
                        'id': DateTime.now().millisecondsSinceEpoch,
                        'nom': medicament['nom'],
                        'dosage': medicament['dosage'],
                        'heure': '${heureSelectionnee.hour.toString().padLeft(2, '0')}:${heureSelectionnee.minute.toString().padLeft(2, '0')}',
                        'nombreComprimes': nombreComprimes,
                        'aJeun': aJeun,
                        'stock': stock,
                        'image': medicament['image'],
                      });
                    });
                    _savePosologie();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Ajouter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            child: const Column(
              children: [
                Icon(Icons.delete_forever, color: Colors.white, size: 30),
                SizedBox(height: 8),
                Text(
                  'Confirmer la suppression',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer ce médicament de votre posologie ?',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  maPosologie.removeWhere((med) => med['id'] == id);
                });
                _savePosologie();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Supprimer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                title: const Text(
                  'Médicaments',
                  style: TextStyle(
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
                        Color(0xFF6C63FF),
                        Color(0xFF4CAF50),
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
                                colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(Icons.local_pharmacy, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Médicaments disponibles',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E3A59),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Liste des médicaments disponibles
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
                                  Text(
                                    medicament['description'],
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              trailing: ElevatedButton(
                                onPressed: () => _ajouterMedicament(medicament),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6C63FF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                                child: const Text(
                                  'Ajouter',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Section Ma posologie
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4CAF50), Color(0xFF6C63FF)],
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(Icons.schedule, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Ma posologie',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E3A59),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Liste de la posologie
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
                              'Aucun médicament ajouté à votre posologie',
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
                                          'À jeun',
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
                                          '${medicament['nombreComprimes']} comprimé(s)',
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
                                          'Stock: ${medicament['stock']}',
                                          style: TextStyle(
                                            color: _getStockColor(medicament['stock']),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () => _supprimerMedicament(medicament['id']),
                                      icon: Icon(Icons.delete, color: Colors.red[600], size: 20),
                                      tooltip: 'Supprimer',
                                    ),
                                  ],
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
  }
}