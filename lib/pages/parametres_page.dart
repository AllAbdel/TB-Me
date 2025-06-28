// ===== lib/pages/parametres_page.dart =====
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/language_provider.dart';
import '../services/notification_service.dart';
import 'dart:io'; // Importer dart:io pour utiliser exit(0)

class ParametresPage extends StatefulWidget {
  const ParametresPage({super.key});

  @override
  _ParametresPageState createState() => _ParametresPageState();
}

class _ParametresPageState extends State<ParametresPage> {
  final LanguageProvider _languageProvider = LanguageProvider();

  String _tr(String key) {
    return _languageProvider.translate(key);
  }

  Future<void> _changeLanguage(String languageCode) async {
    // Utiliser la nouvelle méthode changeLanguage
    await _languageProvider.changeLanguage(languageCode);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_tr('settings.language_changed')} ${_languageProvider.languages[languageCode]!['name']}'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  
// Fonction _resetData corrigée
Future<void> _resetData() async {
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
              const Icon(Icons.warning, color: Colors.white, size: 30),
              const SizedBox(height: 8),
              Text(
                _tr('settings.reset_data'),
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _tr('settings.reset_confirmation'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Text(
                _tr('settings.reset_warning'),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.orange[700],
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_tr('common.cancel'), style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              
              // CORRECTION : Sauvegarder la langue AVANT de tout supprimer
              final currentLang = _languageProvider.currentLanguage;
              
              // Supprimer TOUTES les données
              await prefs.clear();
              
              // Remettre seulement la langue
              await prefs.setString('language', currentLang);
              
              // NOUVEAU : Forcer le rechargement de l'état de la page médicaments
              // en fermant cette page et en revenant à l'accueil
              Navigator.pop(context); // Fermer le dialog
              
              // Optionnel : Rediriger vers l'accueil pour voir les changements
              Navigator.pushNamedAndRemoveUntil(
                context, 
                '/', // ou votre route d'accueil
                (route) => false,
              );
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_tr('settings.reset_success')),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(_tr('common.reset'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      );
    },
  );
}

// Fonction pour quitter l'app corrigée
void _quitApp() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[400]!, Colors.grey[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            const Icon(Icons.exit_to_app, color: Colors.white, size: 30),
            const SizedBox(height: 8),
            Text(
              _tr('settings.quit_app'),
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      content: Text(
        _tr('settings.quit_confirmation'),
        style: const TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(_tr('common.cancel'), style: TextStyle(color: Colors.grey[600])),
        ),
        ElevatedButton(
          onPressed: () {
            // CORRECTION : Importer dart:io en haut du fichier puis utiliser :
            exit(0); // Ferme complètement l'application
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[600],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(_tr('common.quit'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}

  void _showTBMInfo() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "TB&Me",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Application faite par :\n"
                "\nAbdelslam ALLAOUAT \nContact : Abdelslam.allaouat.pro@gmail.com "
                "\n& \n"
                "Pedro GOMES \n\n"
                "En collaboration avec le CLAT 91 :\n"
                "Audrey CRESPEL\n"
                "Cassandra CROCHEMAR\n"
                "Severine CHAPEAU",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                "© 2023 Centre de Lutte Antituberculeuse de l'Essonne (CLAT 91). Tous droits réservés.",
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fermer"),
          ),
        ],
      );
    },
  );
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
                    _tr('app.settings'),
                    style: const TextStyle(
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
                      // Section Langue
                      _buildSectionTitle(
                        icon: Icons.language,
                        title: _tr('settings.language_choice'),
                        color: const Color(0xFF2196F3),
                      ),
                      const SizedBox(height: 16),

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
                            children: _languageProvider.languages.entries.map((entry) {
                              final isSelected = entry.key == _languageProvider.currentLanguage;
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isSelected 
                                      ? [const Color(0xFF2196F3).withOpacity(0.1), Colors.white]
                                      : [Colors.grey[50]!, Colors.white],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF2196F3) : Colors.grey[200]!,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isSelected
                                          ? [const Color(0xFF2196F3).withOpacity(0.2), const Color(0xFF2196F3).withOpacity(0.1)]
                                          : [Colors.grey[100]!, Colors.white],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected ? const Color(0xFF2196F3).withOpacity(0.5) : Colors.grey[300]!,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        entry.value['flag']!,
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    entry.value['name']!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isSelected ? const Color(0xFF2196F3) : const Color(0xFF2E3A59),
                                    ),
                                  ),
                                  trailing: isSelected
                                    ? Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF2196F3),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.check, color: Colors.white, size: 16),
                                      )
                                    : Icon(Icons.radio_button_unchecked, color: Colors.grey[400]),
                                  onTap: () => _changeLanguage(entry.key),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Section Actions avec traductions
                        ElevatedButton.icon(
                          onPressed: () async {
                            print('Test notification démarré'); // Debug
                            
                            try {
                              await NotificationService.showSimpleTestNotification();
                              print('Notification envoyée avec succès'); // Debug
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Notification test envoyée immédiatement')),
                              );
                            } catch (e) {
                              print('Erreur notification: $e'); // Debug
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erreur: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.notifications_active),
                          label: const Text('🔔 Test Simple'),
                        ),

                        _buildSectionTitle(
                          icon: Icons.settings,
                          title: _tr('settings.actions'),
                          color: const Color(0xFFFF9800),
                        ),

                        const SizedBox(height: 16),

                        // Bouton Réinitialiser
                        _buildActionButton(
                          title: _tr('settings.reset_data'),
                          subtitle: _tr('settings.reset_description'),
                          icon: Icons.refresh,
                          color: Colors.red,
                          onTap: _resetData,
                        ),
                        const SizedBox(height: 16),
                        // Bouton Quitter
                        _buildActionButton(
                          title: _tr('settings.quit_app'),
                          subtitle: _tr('settings.quit_description'),
                          icon: Icons.exit_to_app,
                          color: Colors.grey,
                          onTap: _quitApp, // Utiliser la nouvelle fonction
                        ),
                        const SizedBox(height: 32),
                        Center(
                        child: ElevatedButton(
                          onPressed: _showTBMInfo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text("TB&Me"),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Section Info App
                      Container(
                        width: double.infinity,
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
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _tr('app.description'),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 100),
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

  Widget _buildSectionTitle({required IconData icon, required String title, required Color color}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.7)],
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E3A59),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required MaterialColor color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color[50]!, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color[600], size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color[700],
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: color[600],
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: color[600], size: 16),
        onTap: onTap,
      ),
    );
  }
  
}