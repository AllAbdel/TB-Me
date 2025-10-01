// ===== lib/pages/quiz_page.dart =====
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/language_provider.dart';
import 'dart:convert';
import '../widgets/credits_widget.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with TickerProviderStateMixin {
  final LanguageProvider _languageProvider = LanguageProvider();
  
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _quizCompleted = false;
  bool _answerSelected = false;
  int? _selectedAnswerIndex;
  bool _showCorrectAnswer = false;
  
  late AnimationController _progressController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  List<Map<String, dynamic>> _questions = [];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    
    _loadQuestions();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  String _tr(String key) {
    return _languageProvider.translate(key);
  }

  void _loadQuestions() {
    _questions = [
      {
        'question': 'quiz.q1.question',
        'answers': ['quiz.q1.a1', 'quiz.q1.a2', 'quiz.q1.a3', 'quiz.q1.a4'],
        'correct': 1,
        'explanation': 'quiz.q1.explanation'
      },
      {
        'question': 'quiz.q2.question',
        'answers': ['quiz.q2.a1', 'quiz.q2.a2', 'quiz.q2.a3', 'quiz.q2.a4'],
        'correct': 0,
        'explanation': 'quiz.q2.explanation'
      },
      {
        'question': 'quiz.q3.question',
        'answers': ['quiz.q3.a1', 'quiz.q3.a2', 'quiz.q3.a3', 'quiz.q3.a4'],
        'correct': 2,
        'explanation': 'quiz.q3.explanation'
      },
      {
        'question': 'quiz.q5.question',
        'answers': ['quiz.q5.a1', 'quiz.q5.a2', 'quiz.q5.a3', 'quiz.q5.a4'],
        'correct': 0,
        'explanation': 'quiz.q5.explanation'
      },
      {
        'question': 'quiz.q6.question',
        'answers': ['quiz.q6.a1', 'quiz.q6.a2', 'quiz.q6.a3', 'quiz.q6.a4'],
        'correct': 3,
        'explanation': 'quiz.q6.explanation'
      },
      {
        'question': 'quiz.q7.question',
        'answers': ['quiz.q7.a1', 'quiz.q7.a2', 'quiz.q7.a3', 'quiz.q7.a4'],
        'correct': 1,
        'explanation': 'quiz.q7.explanation'
      },
      {
        'question': 'quiz.q8.question',
        'answers': ['quiz.q8.a1', 'quiz.q8.a2', 'quiz.q8.a3', 'quiz.q8.a4'],
        'correct': 2,
        'explanation': 'quiz.q8.explanation'
      },
    ];
  }

  void _selectAnswer(int answerIndex) {
    if (_answerSelected) return;

    setState(() {
      _selectedAnswerIndex = answerIndex;
      _answerSelected = true;
      _showCorrectAnswer = true;
      
      if (answerIndex == _questions[_currentQuestionIndex]['correct']) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _answerSelected = false;
        _selectedAnswerIndex = null;
        _showCorrectAnswer = false;
      });
      
      _progressController.animateTo((_currentQuestionIndex + 1) / _questions.length);
      
      // Animation de transition
      _fadeController.reset();
      _fadeController.forward();
    } else {
      _completeQuiz();
    }
  }

  void _completeQuiz() {
    setState(() {
      _quizCompleted = true;
    });
    _saveQuizResult();
  }

  Future<void> _saveQuizResult() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final result = {
      'score': _score,
      'total': _questions.length,
      'percentage': ((_score / _questions.length) * 100).round(),
      'date': now.toIso8601String(),
    };
    
    List<String> previousResults = prefs.getStringList('quiz_results') ?? [];
    previousResults.add(json.encode(result));
    await prefs.setStringList('quiz_results', previousResults);
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _quizCompleted = false;
      _answerSelected = false;
      _selectedAnswerIndex = null;
      _showCorrectAnswer = false;
    });
    
    _progressController.reset();
    _fadeController.reset();
    _fadeController.forward();
  }

  Color _getAnswerColor(int answerIndex) {
    if (!_showCorrectAnswer) {
      return _selectedAnswerIndex == answerIndex 
        ? const Color(0xFF42A5F5) // Bleu plus foncé si sélectionné
        : const Color(0xFF81D4FA); // Bleu clair par défaut
    }
    
    if (answerIndex == _questions[_currentQuestionIndex]['correct']) {
      return const Color(0xFF66BB6A);
    } else if (answerIndex == _selectedAnswerIndex) {
      return const Color(0xFFEF5350);
    }
    return const Color(0xFF81D4FA); // Bleu clair pour les non-sélectionnées
  }

  Color _getAnswerTextColor(int answerIndex) {
    if (!_showCorrectAnswer) {
      return Colors.black; // Texte noir par défaut
    }
    
    if (answerIndex == _questions[_currentQuestionIndex]['correct'] || 
        answerIndex == _selectedAnswerIndex) {
      return Colors.white; // Texte blanc pour les réponses correctes/incorrectes
    }
    return Colors.black; // Texte noir pour les autres
  }

  IconData _getAnswerIcon(int answerIndex) {
    if (!_showCorrectAnswer) {
      return _selectedAnswerIndex == answerIndex ? Icons.radio_button_checked : Icons.radio_button_unchecked;
    }
    
    if (answerIndex == _questions[_currentQuestionIndex]['correct']) {
      return Icons.check_circle;
    } else if (answerIndex == _selectedAnswerIndex) {
      return Icons.cancel;
    }
    return Icons.radio_button_unchecked;
  }

  Color _getAnswerIconColor(int answerIndex) {
    if (!_showCorrectAnswer) {
      return Colors.black; // Icônes noires par défaut
    }
    
    if (answerIndex == _questions[_currentQuestionIndex]['correct'] || 
        answerIndex == _selectedAnswerIndex) {
      return Colors.white; // Icônes blanches pour les réponses correctes/incorrectes
    }
    return Colors.black; // Icônes noires pour les autres
  }

  String _getScoreMessage() {
    double percentage = (_score / _questions.length) * 100;
    if (percentage >= 80) {
      return _tr('quiz.result.excellent');
    } else if (percentage >= 60) {
      return _tr('quiz.result.good');
    } else if (percentage >= 40) {
      return _tr('quiz.result.average');
    } else {
      return _tr('quiz.result.needs_improvement');
    }
  }

  Color _getScoreColor() {
    double percentage = (_score / _questions.length) * 100;
    if (percentage >= 80) return const Color(0xFF66BB6A);
    if (percentage >= 60) return const Color(0xFF42A5F5);
    if (percentage >= 40) return const Color(0xFFFF9800);
    return const Color(0xFFEF5350);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _languageProvider,
      builder: (context, child) {
        return Scaffold(
          body: Container(
            // FOND BLANC pour toute la page
            color: Colors.white,
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 120,
                  floating: false,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  iconTheme: const IconThemeData(color: Colors.white),
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      _tr('app.quiz'),
                      style: const TextStyle(
                        color: Colors.white,
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
                            Color(0xFF1565C0), // Bleu très foncé
                            Color(0xFF1E88E5), // Bleu foncé
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _quizCompleted ? _buildResultScreen() : _buildQuizScreen(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuizScreen() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Barre de progression
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_tr('quiz.question')} ${_currentQuestionIndex + 1}/${_questions.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1565C0), // Texte bleu foncé
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        '${_tr('quiz.score')}: $_score',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _progressController.value,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1565C0)),
                          minHeight: 12,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Question - FOND BLEU
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF42A5F5), // Bleu moyen
                  Color(0xFF1E88E5), // Bleu foncé
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white, // Fond blanc pour l'icône
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.quiz,
                    color: Color(0xFF1565C0), // Icône bleue
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _tr(_questions[_currentQuestionIndex]['question']),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Texte blanc sur fond bleu
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Réponses - BULLES BLEU CLAIR
          Column(
            children: List.generate(4, (index) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                  child: InkWell(
                    onTap: _answerSelected ? null : () => _selectAnswer(index),
                    borderRadius: BorderRadius.circular(15),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getAnswerColor(index),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: _getAnswerColor(index).withOpacity(0.5),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _getAnswerColor(index).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Icon(
                                _getAnswerIcon(index),
                                color: _getAnswerIconColor(index),
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _tr(_questions[_currentQuestionIndex]['answers'][index]),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _getAnswerTextColor(index), // Texte noir/blanc selon le contexte
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          // Explication + Bouton suivant
          if (_showCorrectAnswer) ...[
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF42A5F5).withOpacity(0.1), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFF42A5F5).withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.lightbulb, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _tr('quiz.explanation'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _tr(_questions[_currentQuestionIndex]['explanation']),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF455A64),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Bouton pour passer à la question suivante
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1E88E5).withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                        child: InkWell(
                          onTap: _nextQuestion,
                          borderRadius: BorderRadius.circular(25),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.play_arrow, color: Colors.white, size: 24),
                                const SizedBox(width: 8),
                                Container(
                                  width: 2,
                                  height: 20,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.skip_next, color: Colors.white, size: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    final percentage = ((_score / _questions.length) * 100).round();
    final scoreColor = _getScoreColor();

    return Column(
      children: [
        // Résultat principal
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.white.withOpacity(0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [scoreColor.withOpacity(0.2), scoreColor.withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  percentage >= 80 ? Icons.emoji_events : 
                  percentage >= 60 ? Icons.thumb_up : 
                  percentage >= 40 ? Icons.school : Icons.refresh,
                  color: scoreColor,
                  size: 60,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _tr('quiz.result.title'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getScoreMessage(),
                style: TextStyle(
                  fontSize: 16,
                  color: scoreColor,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF42A5F5).withOpacity(0.1), Colors.white],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFF42A5F5).withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      '$_score / ${_questions.length}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                    Text(
                      '$percentage%',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Boutons d'action
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E88E5).withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _restartQuiz,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: Text(
                    _tr('quiz.restart'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home, color: Colors.white),
                  label: Text(
                    _tr('quiz.home'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const CreditsWidget(),
        const SizedBox(height: 20),
    ],
    );
  }
}