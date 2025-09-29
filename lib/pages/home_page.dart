import 'package:flutter/material.dart';
import '../providers/language_provider.dart';
import 'accueil_principale_page.dart';
import 'accueil_page.dart';
import 'medicaments_page.dart';
import 'quiz_page.dart';
import 'calendrier_page.dart';
import 'informations_page.dart';
import 'parametres_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LanguageProvider _languageProvider = LanguageProvider();
  int _currentIndex = 0;

  String _tr(String key) => _languageProvider.translate(key);

  final List<Widget> _pages = [
    const AccueilPrincipalePage(),
    const AccueilPage(),
    const MedicamentsPage(),
    const CalendrierPage(),
    const QuizPage(),
    const InformationsPage(),
    const ParametresPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _languageProvider,
      builder: (context, child) {
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.9),
                  Colors.white,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              selectedItemColor: const Color(0xFF6C63FF),
              unselectedItemColor: const Color.fromARGB(255, 0, 0, 0),
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              unselectedLabelStyle: const TextStyle(fontSize: 10),
              backgroundColor: Colors.transparent,
              elevation: 0,
              items: [
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _currentIndex == 0 ? const Color(0xFF6C63FF).withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.home, size: 22),
                  ),
                  label: _tr('app.home'),
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _currentIndex == 1 ? const Color(0xFF6C63FF).withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.dashboard, size: 22),
                  ),
                  label: _tr('app.mangement'),
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _currentIndex == 2 ? const Color(0xFF6C63FF).withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.medication, size: 22),
                  ),
                  label: _tr('app.medications'),
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _currentIndex == 3 ? const Color(0xFF6C63FF).withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.calendar_today, size: 22),
                  ),
                  label: _tr('app.calendar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}