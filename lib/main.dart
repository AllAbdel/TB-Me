// ===== lib/main.dart =====
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'providers/language_provider.dart';
import 'pages/accueil_page.dart';
import 'pages/medicaments_page.dart';
import 'pages/quiz_page.dart';
import 'pages/informations_page.dart';
import 'pages/parametres_page.dart';
import 'localizations/app_localizations.dart';
import 'services/notification_service.dart';
import 'services/permission_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser le LanguageProvider AVANT les notifications
  final languageProvider = LanguageProvider();
  await languageProvider.initialize();
  
  // Initialiser les notifications
  await NotificationService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TB&Me',
      theme: ThemeData(
        // Thème bleu principal
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF1565C0),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
        ),
        // AppBar theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1565C0),
          foregroundColor: Colors.white,
          elevation: 4,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        // ElevatedButton theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF42A5F5),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        // Card theme
        cardTheme: const CardThemeData(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
      home: const PermissionWrapper(),
      supportedLocales: const [
        Locale('fr', ''), Locale('en', ''), Locale('ar', ''),
        Locale('pt', ''), Locale('es', ''), Locale('ru', ''),
        Locale('zh', ''), Locale('ps', ''), Locale('fa', ''),
        Locale('ko', ''), Locale('ja', ''), Locale('hy', ''),
        Locale('bm', ''), Locale('ka', ''), Locale('hi', ''),
        Locale('mg', ''), Locale('ff', ''), Locale('so', ''),
        Locale('ta', ''), Locale('de', ''), Locale('it', ''),
        Locale('bn', ''), Locale('sd', ''), Locale('md', ''),
        Locale('ur', ''), Locale('tr', ''), Locale('th', ''),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
    );
  }
}

// Widget pour gérer les permissions au démarrage
class PermissionWrapper extends StatefulWidget {
  const PermissionWrapper({super.key});

  @override
  _PermissionWrapperState createState() => _PermissionWrapperState();
}

class _PermissionWrapperState extends State<PermissionWrapper> {
  bool _permissionsRequested = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Attendre que l'interface soit prête
    await Future.delayed(const Duration(milliseconds: 1000));
    
    if (mounted) {
      // Demander les permissions
      await PermissionService.requestAllPermissions(context);
      
      // Attendre encore un peu pour que l'utilisateur voie le message
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _permissionsRequested = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1565C0), // Bleu très foncé
                Color(0xFF1E88E5), // Bleu foncé
                Color(0xFF42A5F5), // Bleu moyen
                Color(0xFF81D4FA), // Bleu clair
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(70),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.medical_services, 
                    size: 70, 
                    color: Colors.white
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'TB&Me',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Suivi de traitement',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Initialisation...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9), 
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return const MainPage();
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final LanguageProvider _languageProvider = LanguageProvider();

  // Clés globales pour accéder aux pages
  final GlobalKey<AccueilPageState> _accueilKey = GlobalKey<AccueilPageState>();
  final GlobalKey<MedicamentsPageState> _medicamentsKey = GlobalKey<MedicamentsPageState>();

  String _tr(String key) {
    return _languageProvider.translate(key);
  }

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      AccueilPage(key: _accueilKey),
      MedicamentsPage(key: _medicamentsKey),
      const QuizPage(),
      const InformationsPage(),
      const ParametresPage(),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Rafraîchir les données quand on change d'onglet
    if (index == 0) {
      // Onglet Accueil - recharger les données
      _accueilKey.currentState?.refreshData();
    } else if (index == 1) {
      // Onglet Médicaments - recharger la posologie
      _medicamentsKey.currentState?.refreshPosologie();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: _languageProvider,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1565C0), // Bleu très foncé
                  Color(0xFF1E88E5), // Bleu foncé
                  Color(0xFF42A5F5), // Bleu moyen
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1565C0).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: _onTabTapped,
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.white.withOpacity(0.6),
                selectedFontSize: 12,
                unselectedFontSize: 10,
                items: [
                  BottomNavigationBarItem(
                    icon: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: _currentIndex == 0 
                          ? LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.3),
                                Colors.white.withOpacity(0.1),
                              ],
                            )
                          : null,
                        borderRadius: BorderRadius.circular(15),
                        border: _currentIndex == 0 
                          ? Border.all(color: Colors.white.withOpacity(0.4), width: 2)
                          : null,
                        boxShadow: _currentIndex == 0 
                          ? [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                      ),
                      child: const Icon(Icons.home, size: 24),
                    ),
                    label: _tr('app.home'),
                  ),
                  BottomNavigationBarItem(
                    icon: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: _currentIndex == 1 
                          ? LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.3),
                                Colors.white.withOpacity(0.1),
                              ],
                            )
                          : null,
                        borderRadius: BorderRadius.circular(15),
                        border: _currentIndex == 1 
                          ? Border.all(color: Colors.white.withOpacity(0.4), width: 2)
                          : null,
                        boxShadow: _currentIndex == 1 
                          ? [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                      ),
                      child: const Icon(Icons.medication, size: 24),
                    ),
                    label: _tr('app.medications'),
                  ),
                  BottomNavigationBarItem(
                    icon: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: _currentIndex == 2 
                          ? LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.3),
                                Colors.white.withOpacity(0.1),
                              ],
                            )
                          : null,
                        borderRadius: BorderRadius.circular(15),
                        border: _currentIndex == 2 
                          ? Border.all(color: Colors.white.withOpacity(0.4), width: 2)
                          : null,
                        boxShadow: _currentIndex == 2 
                          ? [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                      ),
                      child: const Icon(Icons.quiz, size: 24),
                    ),
                    label: _tr('app.quiz'),
                  ),
                  BottomNavigationBarItem(
                    icon: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: _currentIndex == 3 
                          ? LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.3),
                                Colors.white.withOpacity(0.1),
                              ],
                            )
                          : null,
                        borderRadius: BorderRadius.circular(15),
                        border: _currentIndex == 3 
                          ? Border.all(color: Colors.white.withOpacity(0.4), width: 2)
                          : null,
                        boxShadow: _currentIndex == 3 
                          ? [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                      ),
                      child: const Icon(Icons.info, size: 24),
                    ),
                    label: _tr('app.information'),
                  ),
                  BottomNavigationBarItem(
                    icon: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: _currentIndex == 4 
                          ? LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.3),
                                Colors.white.withOpacity(0.1),
                              ],
                            )
                          : null,
                        borderRadius: BorderRadius.circular(15),
                        border: _currentIndex == 4 
                          ? Border.all(color: Colors.white.withOpacity(0.4), width: 2)
                          : null,
                        boxShadow: _currentIndex == 4 
                          ? [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                      ),
                      child: const Icon(Icons.settings, size: 24),
                    ),
                    label: _tr('app.settings'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}