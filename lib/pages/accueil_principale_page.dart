// ===== lib/pages/accueil_principale_page.dart =====
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/language_provider.dart';
import '../widgets/tutorial_overlay.dart';
import '../widgets/credits_widget.dart';
import 'accueil_page.dart';
import 'medicaments_page.dart';
import 'quiz_page.dart';
import 'calendrier_page.dart';
import 'historique_page.dart';
import 'informations_page.dart';
import 'parametres_page.dart';

class AccueilPrincipalePage extends StatefulWidget {
  const AccueilPrincipalePage({super.key});

  @override
  State<AccueilPrincipalePage> createState() => _AccueilPrincipalePageState();
}

class _AccueilPrincipalePageState extends State<AccueilPrincipalePage> {
  final LanguageProvider _languageProvider = LanguageProvider();
  bool _showTutorial = false;

  String _tr(String key) => _languageProvider.translate(key);

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenTutorial = prefs.getBool('has_seen_tutorial') ?? false;
    
    if (!hasSeenTutorial) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() => _showTutorial = true);
      }
    }
  }

  Future<void> _completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_tutorial', true);
    setState(() => _showTutorial = false);
  }

  void showTutorial() {
    setState(() => _showTutorial = true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _languageProvider,
      builder: (context, child) {
        return Stack(
          children: [
            Scaffold(
              body: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF1565C0),
                      Color(0xFF1E88E5),
                      Colors.white,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // En-tête
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
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
                                const Icon(
                                  Icons.medical_services,
                                  size: 60,
                                  color: Color(0xFF1565C0),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _tr('app.title'),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E3A59),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _tr('home.welcome'),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Grille de tuiles
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            children: [
                              _buildNavigationTile(
                                context: context,
                                title: _tr('app.mangement'),
                                icon: Icons.dashboard,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                                ),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const AccueilPage()),
                                ),
                              ),
                              _buildNavigationTile(
                                context: context,
                                title: _tr('app.medications'),
                                icon: Icons.medication,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF2196F3), Color(0xFF42A5F5)],
                                ),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const MedicamentsPage()),
                                ),
                              ),
                              _buildNavigationTile(
                                context: context,
                                title: _tr('app.calendar'),
                                icon: Icons.calendar_today,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF009688), Color(0xFF26A69A)],
                                ),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const CalendrierPage()),
                                ),
                              ),
                              _buildNavigationTile(
                                context: context,
                                title: _tr('app.history'),
                                icon: Icons.history,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF9C27B0), Color(0xFFAB47BC)],
                                ),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const HistoriquePage()),
                                ),
                              ),
                              _buildNavigationTile(
                                context: context,
                                title: _tr('app.quiz'),
                                icon: Icons.quiz,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFF9800), Color(0xFFFFA726)],
                                ),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const QuizPage()),
                                ),
                              ),
                              _buildNavigationTile(
                                context: context,
                                title: _tr('app.information'),
                                icon: Icons.info,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)],
                                ),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const InformationsPage()),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Bouton Paramètres
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ParametresPage()),
                              ),
                              icon: const Icon(Icons.settings),
                              label: Text(_tr('app.settings')),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF2E3A59),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 4,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),
                          const CreditsWidget(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Overlay du tutoriel
            if (_showTutorial)
              TutorialOverlay(
                onComplete: _completeTutorial,
              ),
          ],
        );
      },
    );
  }

  Widget _buildNavigationTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 48, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}