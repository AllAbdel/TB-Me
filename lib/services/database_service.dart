import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/medicament.dart';
import '../models/prise_medicament.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  factory DatabaseService() => instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'mytuberculose.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE medicaments(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nom TEXT NOT NULL,
            dosage TEXT NOT NULL,
            frequenceParJour INTEGER NOT NULL,
            heuresPrise TEXT NOT NULL,
            aJeun INTEGER NOT NULL,
            stockRestant INTEGER NOT NULL,
            photoPath TEXT,
            effetsSecondaires TEXT,
            conseils TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE prises_medicaments(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            medicamentId INTEGER NOT NULL,
            datePrise TEXT NOT NULL,
            heurePrevue TEXT NOT NULL,
            heureReelle TEXT,
            pris INTEGER NOT NULL,
            FOREIGN KEY (medicamentId) REFERENCES medicaments (id)
          )
        ''');

        // Insérer des données par défaut
        await _insertDefaultMedicaments(db);
      },
    );
  }

  Future<void> _insertDefaultMedicaments(Database db) async {
    List<Medicament> defaultMeds = [
      Medicament(
        nom: 'Rifadine',
        dosage: '300mg',
        frequenceParJour: 1,
        heuresPrise: ['08:00'],
        aJeun: true,
        stockRestant: 30,
        effetsSecondaires: 'Urine orangée, nausées',
        conseils: 'à prendre à jeun, 1h avant le repas',
      ),
      Medicament(
        nom: 'Rifater',
        dosage: '120mg/50mg/300mg',
        frequenceParJour: 1,
        heuresPrise: ['08:00'],
        aJeun: true,
        stockRestant: 28,
        effetsSecondaires: 'Troubles digestifs, maux de tête',
        conseils: 'Combinaison de 3 médicaments en 1 comprimé',
      ),
    ];

    for (Medicament med in defaultMeds) {
      await db.insert('medicaments', med.toMap());
    }
  }

  // Méthodes CRUD pour les médicaments
  Future<List<Medicament>> getMedicaments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('medicaments');
    return List.generate(maps.length, (i) => Medicament.fromMap(maps[i]));
  }

  Future<int> insertMedicament(Medicament medicament) async {
    final db = await database;
    return await db.insert('medicaments', medicament.toMap());
  }

  Future<void> updateMedicament(Medicament medicament) async {
    final db = await database;
    await db.update(
      'medicaments',
      medicament.toMap(),
      where: 'id = ?',
      whereArgs: [medicament.id],
    );
  }

  // Méthodes pour les prises de médicaments
  Future<List<PriseMedicament>> getPrisesAujourdhui() async {
    final db = await database;
    String today = DateTime.now().toIso8601String().split('T')[0];
    final List<Map<String, dynamic>> maps = await db.query(
      'prises_medicaments',
      where: 'datePrise LIKE ?',
      whereArgs: ['%'],
    );
    return List.generate(maps.length, (i) => PriseMedicament.fromMap(maps[i]));
  }

  Future<void> marquerPriseMedicament(int priseId) async {
  final db = await database;
  final now = DateTime.now();
  final formattedTime = "${now.hour}:${now.minute}";

  await db.update(
    'prises_medicaments',
    {'pris': 1, 'heureReelle': formattedTime},
    where: 'id = ?',
    whereArgs: [priseId],
  );
}

}
