// /lib/services/catchup_service.dart

import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

class CatchupService {
  static const String _catchupKey = 'catchups';

  static Future<void> startCatchup({
    required int medicationId,
    required String medicamentNom,
    required String dosage,
    required int nombreComprimes,
    required int startTime,
    required int endTime,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final catchups = await getActiveCatchups();

    // Supprimer l'ancien rattrapage s'il existe
    await removeCatchup(medicationId);

    final newCatchup = {
      'medicationId': medicationId,
      'medicamentNom': medicamentNom,
      'dosage': dosage,
      'nombreComprimes': nombreComprimes,
      'startTime': startTime,
      'endTime': endTime,
    };

    catchups.add(newCatchup);
    await prefs.setString(_catchupKey, json.encode(catchups));
    print('✅ Rattrapage enregistré pour $medicamentNom (ID: $medicationId)');
  }

  // MODIFIÉ : Retourne aussi les rattrapages expirés mais récents (moins de 5 min)
  static Future<List<Map<String, dynamic>>> getActiveCatchups() async {
    final prefs = await SharedPreferences.getInstance();
    final catchupsJson = prefs.getString(_catchupKey) ?? '[]';
    List<Map<String, dynamic>> catchups = List<Map<String, dynamic>>.from(json.decode(catchupsJson));

    DateTime now = DateTime.now();
    List<Map<String, dynamic>> activeCatchups = catchups.where((catchup) {
      DateTime endTime = DateTime.fromMillisecondsSinceEpoch(catchup['endTime']);
      // Garde les rattrapages actifs OU expirés depuis moins de 5 minutes
      return endTime.isAfter(now.subtract(Duration(minutes: 5)));
    }).toList();

    // Sauvegarder la liste filtrée
    await prefs.setString(_catchupKey, json.encode(activeCatchups));

    return activeCatchups;
  }
  
  // NOUVEAU : Vérifier si un rattrapage est terminé
  static Future<bool> isCatchupCompleted(int medicationId) async {
    final catchups = await getActiveCatchups();
    final catchup = catchups.firstWhere(
      (c) => c['medicationId'] == medicationId,
      orElse: () => <String, dynamic>{},
    );
    
    if (catchup.isEmpty) return false;
    
    DateTime endTime = DateTime.fromMillisecondsSinceEpoch(catchup['endTime']);
    return DateTime.now().isAfter(endTime);
  }

  static Future<void> removeCatchup(int medicationId) async {
    final prefs = await SharedPreferences.getInstance();
    final catchupsJson = prefs.getString(_catchupKey) ?? '[]';
    List<Map<String, dynamic>> catchups = List<Map<String, dynamic>>.from(json.decode(catchupsJson));
    
    catchups.removeWhere((catchup) => catchup['medicationId'] == medicationId);
    await prefs.setString(_catchupKey, json.encode(catchups));
    print('🗑️ Rattrapage supprimé pour ID: $medicationId');
  }

  static String getRandomEncouragement(List<String> messages) {
    if (messages.isEmpty) return "Bravo ! 🎉";
    Random random = Random();
    return messages[random.nextInt(messages.length)];
  }
}