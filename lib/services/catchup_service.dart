import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

class CatchupService {
  static const String _catchupKey = 'catchups';

  // Sauvegarder un rattrapage actif
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

    // Ajouter le nouveau rattrapage
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
  }

  // Récupérer les rattrapages actifs
  static Future<List<Map<String, dynamic>>> getActiveCatchups() async {
    final prefs = await SharedPreferences.getInstance();
    final catchupsJson = prefs.getString(_catchupKey) ?? '[]';
    List<Map<String, dynamic>> catchups = List<Map<String, dynamic>>.from(json.decode(catchupsJson));

    // Filtrer seulement les rattrapages non expirés
    DateTime now = DateTime.now();
    List<Map<String, dynamic>> activeCatchups = catchups.where((catchup) {
      DateTime endTime = DateTime.fromMillisecondsSinceEpoch(catchup['endTime']);
      return endTime.isAfter(now);
    }).toList();

    // Sauvegarder la liste filtrée
    await prefs.setString(_catchupKey, json.encode(activeCatchups));

    return activeCatchups;
  }

  // Supprimer un rattrapage
  static Future<void> removeCatchup(int medicationId) async {
    final prefs = await SharedPreferences.getInstance();
    final catchups = await getActiveCatchups();
    catchups.removeWhere((catchup) => catchup['medicationId'] == medicationId);
    await prefs.setString(_catchupKey, json.encode(catchups));
  }

  // Obtenir un message d'encouragement aléatoire
  static String getRandomEncouragement(List<String> messages) {
    if (messages.isEmpty) return "Bravo ! 🎉";
    Random random = Random();
    return messages[random.nextInt(messages.length)];
  }
}
