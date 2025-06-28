// ===== lib/providers/language_provider.dart =====
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/translation_service.dart';
import 'dart:ui' as ui;

class LanguageProvider extends ChangeNotifier {
  static final LanguageProvider _instance = LanguageProvider._internal();
  factory LanguageProvider() => _instance;
  LanguageProvider._internal();

  final TranslationService _translationService = TranslationService();
  Locale _currentLocale = const Locale('fr', '');
  bool _isInitialized = false;

  Locale get currentLocale => _currentLocale;
  String get currentLanguage => _currentLocale.languageCode;
  bool get isInitialized => _isInitialized;

  final Map<String, Map<String, String>> _languages = {
  'fr': {'name': 'Français', 'flag': '🇫🇷'},
  'en': {'name': 'English', 'flag': '🇬🇧'},
  'ar': {'name': 'العربية', 'flag': '🇸🇦'},
  'pt': {'name': 'Português', 'flag': '🇵🇹'},
  'es': {'name': 'Español', 'flag': '🇪🇸'},
  'ru': {'name': 'Русский', 'flag': '🇷🇺'},
  'zh': {'name': '中文', 'flag': '🇨🇳'},
  'ps': {'name': 'پښتو', 'flag': '🇦🇫'},
  'fa': {'name': 'دری', 'flag': '🇦🇫'},
  // Nouvelles langues :
  'ko': {'name': '한국어', 'flag': '🇰🇷'},
  'ja': {'name': '日本語', 'flag': '🇯🇵'},
  'hy': {'name': 'Հայերեն', 'flag': '🇦🇲'},
  'bm': {'name': 'Bamanankan', 'flag': '🇲🇱'},
  'ka': {'name': 'ქართული', 'flag': '🇬🇪'},
  'hi': {'name': 'हिन्दी', 'flag': '🇮🇳'},
  'mg': {'name': 'Malagasy', 'flag': '🇲🇬'},
  'ff': {'name': 'Fulfulde', 'flag': '🇸🇳'},
  'so': {'name': 'Soomaaliga', 'flag': '🇸🇴'},
  'ta': {'name': 'தமிழ்', 'flag': '🇮🇳'},
  'de': {'name': 'Deutsch', 'flag': '🇩🇪'},
  'it': {'name': 'Italiano', 'flag': '🇮🇹'},
  'bn': {'name': 'বাংলা', 'flag': '🇧🇩'},
  'sd': {'name': 'العربية السودانية', 'flag': '🇸🇩'},
  'md': {'name': 'Moldovenească', 'flag': '🇲🇩'},
  'ur': {'name': 'اردو', 'flag': '🇵🇰'},
  'tr': {'name': 'Türkçe', 'flag': '🇹🇷'},
  'th': {'name': 'ไทย', 'flag': '🇹🇭'},

};

  Map<String, Map<String, String>> get languages => _languages;

  /// Initialise la langue au démarrage de l'application
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      String? savedLanguage = prefs.getString('language');
      
      String languageToLoad;
      
      if (savedLanguage != null && _languages.containsKey(savedLanguage)) {
        // Utiliser la langue sauvegardée si elle existe et est supportée
        languageToLoad = savedLanguage;
        if (kDebugMode) print('Langue sauvegardée trouvée: $languageToLoad');
      } else {
        // Détecter la langue du système
        languageToLoad = _detectSystemLanguage();
        if (kDebugMode) print('Langue du système détectée: $languageToLoad');
        
        // Sauvegarder la langue détectée
        await prefs.setString('language', languageToLoad);
      }
      
      // Charger la langue
      await _loadLanguageInternal(languageToLoad);
      _isInitialized = true;
      
      if (kDebugMode) print('LanguageProvider initialisé avec la langue: $languageToLoad');
      
    } catch (e) {
      if (kDebugMode) print('Erreur lors de l\'initialisation de LanguageProvider: $e');
      // En cas d'erreur, charger le français par défaut
      await _loadLanguageInternal('fr');
      _isInitialized = true;
    }
  }

  /// Détecte la langue du système et retourne une langue supportée
  String _detectSystemLanguage() {
    try {
      String systemLanguageCode;
      
      if (kIsWeb) {
        // Pour le web, utiliser la locale du navigateur
        systemLanguageCode = ui.window.locale.languageCode.toLowerCase();
      } else {
        // Pour mobile, utiliser la locale du système
        systemLanguageCode = ui.window.locale.languageCode.toLowerCase();
      }
      
      if (kDebugMode) print('Code langue système détecté: $systemLanguageCode');
      
      // Vérifier si la langue système est supportée
      if (_languages.containsKey(systemLanguageCode)) {
        return systemLanguageCode;
      }
      
      // Langue système non supportée, utiliser le français par défaut
      if (kDebugMode) print('Langue système non supportée, utilisation du français par défaut');
      return 'fr';
      
    } catch (e) {
      if (kDebugMode) print('Erreur lors de la détection de la langue système: $e');
      return 'fr';
    }
  }

  /// Charge une langue (méthode interne)
  Future<void> _loadLanguageInternal(String languageCode) async {
    try {
      await _translationService.loadLanguage(languageCode);
      _currentLocale = Locale(languageCode, '');
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Erreur lors du chargement de la langue $languageCode: $e');
      // En cas d'erreur, essayer de charger le français
      if (languageCode != 'fr') {
        await _translationService.loadLanguage('fr');
        _currentLocale = const Locale('fr', '');
        notifyListeners();
      }
    }
  }

  /// Change la langue (utilisé par l'interface utilisateur)
  Future<void> changeLanguage(String languageCode) async {
    try {
      await _translationService.loadLanguage(languageCode);
      _currentLocale = Locale(languageCode, '');
      
      // Sauvegarder la nouvelle langue
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', languageCode);
      
      notifyListeners();
      if (kDebugMode) print('Langue changée vers: $languageCode');
      
    } catch (e) {
      if (kDebugMode) print('Erreur lors du changement de langue vers $languageCode: $e');
      // En cas d'erreur, revenir au français
      if (languageCode != 'fr') {
        await changeLanguage('fr');
      }
    }
  }

  /// Retourne la traduction d'une clé
  String translate(String key) {
    if (!_isInitialized) {
      if (kDebugMode) print('LanguageProvider pas encore initialisé, retour de la clé: $key');
      return key;
    }
    return _translationService.translate(key);
  }

  /// Force le rechargement de la langue actuelle
  Future<void> reload() async {
    await _loadLanguageInternal(_currentLocale.languageCode);
  }
}