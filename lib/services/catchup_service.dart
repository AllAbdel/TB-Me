import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

class CatchupService {
  static const String _catchupKey = 'active_catchups';
  
  // Sauvegarder un rattrapage actif
  static Future<void> startCatchup({
    required int medicationId,
    required String medicamentNom,
    required String dosage,
    required int nombreComprimes,
    required DateTime startTime,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    Map<String, dynamic> catchupData = {
      'medicationId': medicationId,
      'medicamentNom': medicamentNom,
      'dosage': dosage,
      'nombreComprimes': nombreComprimes,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': startTime.add(const Duration(hours: 2)).millisecondsSinceEpoch,
    };
    
    // Récupérer les rattrapages existants
    String? existingData = prefs.getString(_catchupKey);
    List<Map<String, dynamic>> catchups = [];
    
    if (existingData != null) {
      catchups = List<Map<String, dynamic>>.from(json.decode(existingData));
    }
    
    // Ajouter le nouveau rattrapage
    catchups.add(catchupData);
    
    // Sauvegarder
    await prefs.setString(_catchupKey, json.encode(catchups));
  }
  
  // Récupérer les rattrapages actifs
  static Future<List<Map<String, dynamic>>> getActiveCatchups() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString(_catchupKey);
    
    if (data == null) return [];
    
    List<Map<String, dynamic>> catchups = List<Map<String, dynamic>>.from(json.decode(data));
    DateTime now = DateTime.now();
    
    // Filtrer seulement les rattrapages non expirés
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
    String? data = prefs.getString(_catchupKey);
    
    if (data == null) return;
    
    List<Map<String, dynamic>> catchups = List<Map<String, dynamic>>.from(json.decode(data));
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