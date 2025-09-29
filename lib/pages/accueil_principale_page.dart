// ===== lib/pages/accueil_principale_page.dart =====
import 'package:flutter/material.dart';
import '../providers/language_provider.dart';
import 'accueil_page.dart'; // Votre page existante (tableau de bord)
import 'medicaments_page.dart';
import 'quiz_page.dart';
import 'calendrier_page.dart';
import 'historique_page.dart';
import 'informations_page.dart';
import 'parametres_page.dart';
import '../widgets/credits_widget.dart';


class AccueilPrincipalePage extends StatefulWidget {
  const AccueilPrincipalePage({super.key});

  @override
  State<AccueilPrincipalePage> createState() => _AccueilPrincipalePageState();
}

class _AccueilPrincipalePageState extends State<AccueilPrincipalePage> {
  final LanguageProvider _languageProvider = LanguageProvider();

  String _tr(String key) => _languageProvider.translate(key);

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
                      // En-tête avec logo/titre
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
                              _tr('app.title') ?? 'My Tuberculose',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E3A59),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _tr('home.welcome') ?? 'Bienvenue !',
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

                      // Grille de tuiles de navigation
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          _buildNavigationTile(
                            context: context,
                            title: _tr('app.mangement') ?? 'Mes prises de médicaments',
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
                            title: _tr('app.medications') ?? 'Médicaments',
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
                            title: _tr('app.calendar') ?? 'Calendrier',
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
                            title: _tr('app.history') ?? 'Historique',
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
                            title: _tr('app.quiz') ?? 'Quiz',
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
                            title: _tr('app.information') ?? 'Informations',
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

                      // Bouton Paramètres en bas
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ParametresPage()),
                          ),
                          icon: const Icon(Icons.settings),
                          label: Text(_tr('app.settings') ?? 'Paramètres'),
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
                    ],
                  ),
                ),
              ),
            ),
          ),
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
                  Icon(
                    icon,
                    size: 48,
                    color: Colors.white,
                  ),
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