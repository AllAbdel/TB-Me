// ===== lib/widgets/credits_widget.dart =====
import 'package:flutter/material.dart';
import '../providers/language_provider.dart';

class CreditsWidget extends StatelessWidget {
  const CreditsWidget({super.key});

  void _showTBMInfo(BuildContext context) {
    final languageProvider = LanguageProvider();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "À propos de TB&Me",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Application réalisée par :\n"
                  "\nIUT Evry Paris-Saclay :\n"
                  "Abdelslam ALLAOUAT\n "
                  "& \n"
                  "Pedro GOMES \n\n"
                  "En collaboration avec le CLAT 91 :\n"
                  "Audrey CRESPEL\n"
                  "Cassandra CROCHEMAR\n"
                  "Severine CHAPEAU",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                Text(
                  "© 2025 Centre de Lutte Antituberculeuse de l'Essonne (CLAT 91).\n"
                  "IUT Evry Paris Sacaly.\n"
                  "Tous droits réservés.",
                  style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(languageProvider.translate('common.close')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = LanguageProvider();
    
    return GestureDetector(
      onTap: () => _showTBMInfo(context),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 40, bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF6C63FF).withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
        ),
        child: Column(
          children: [
            const Icon(Icons.medical_services, color: Color(0xFF6C63FF), size: 40),
            const SizedBox(height: 12),
            const Text(
              'TB&Me',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3A59),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 14,
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              languageProvider.translate('app.description'),
              style: TextStyle(
                fontSize: 12,
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(languageProvider.translate('information.title'),
                  style: TextStyle(
                    fontSize: 11,
                    color: const Color.fromARGB(255, 0, 0, 0),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}