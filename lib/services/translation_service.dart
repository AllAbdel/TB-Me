// ===== lib/services/translation_service.dart =====

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  Map<String, dynamic> _localizedStrings = {};
  String _currentLanguage = 'fr';

  Future<void> loadLanguage(String languageCode) async {
    try {
      String jsonString = await rootBundle.loadString('assets/translations/$languageCode.json');
      _localizedStrings = json.decode(jsonString);
      _currentLanguage = languageCode;
    } catch (e) {
      print('Erreur lors du chargement de la langue $languageCode: $e');
      // Charger le français par défaut en cas d'erreur
      if (languageCode != 'fr') {
        await loadLanguage('fr');
      }
    }
  }
  
  String translate(String key) {
    List<String> keys = key.split('.');
    dynamic value = _localizedStrings;

    for (String k in keys) {
      if (value is Map && value.containsKey(k)) {
        value = value[k];
      } else {
        return key; // Retourne la clé si la traduction n'est pas trouvée
      }
    }

    return value.toString();
  }

  // AJOUTER CETTE MÉTHODE ICI :
  Map<String, dynamic> getAllTranslations() {
    return _localizedStrings;
  }

  String get currentLanguage => _currentLanguage;

  static TranslationService of(BuildContext context) {
    return _instance;
  }
}

// Extension pour simplifier l'utilisation
extension TranslationExtension on String {
  String tr(BuildContext context) {
    return TranslationService.of(context).translate(this);
  }
}