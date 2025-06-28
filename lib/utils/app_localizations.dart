import 'package:flutter/material.dart';

class AppLocalizations {
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // Méthodes de traduction (Ã  compléter)
  String get appTitle => 'MyTuberculose';
  String get home => 'Accueil';
  String get medications => 'Médicaments';
  String get quiz => 'Quiz';
  String get information => 'Informations';
  String get settings => 'Paramètres';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['fr', 'en', 'ar', 'pt', 'es', 'ru','zh','pashto','dari'].contains(locale.languageCode);
  }
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations();
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
