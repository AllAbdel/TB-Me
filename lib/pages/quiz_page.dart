// ===== lib/pages/quiz_page.dart =====
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/language_provider.dart';
import 'dart:convert';

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
        'question': 'quiz.q4.question',
        'answers': ['quiz.q4.a1', 'quiz.q4.a2', 'quiz.q4.a3', 'quiz.q4.a4'],
        'correct': 1,
        'explanation': 'quiz.q4.explanation'
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

    // Attendre 3 secondes avant de passer à la question suivante
    Future.delayed(const Duration(seconds: 3), () {
      _nextQuestion();
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
      return _selectedAnswerIndex == answerIndex ? const Color(0xFF6C63FF) : const Color.fromARGB(22, 0, 0, 0);
    }
    
    if (answerIndex == _questions[_currentQuestionIndex]['correct']) {
      return Colors.green;
    } else if (answerIndex == _selectedAnswerIndex) {
      return Colors.red;
    }
    return Colors.grey[200]!;
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
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.blue;
    if (percentage >= 40) return Colors.orange;
    return Colors.red;
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
                  Color.fromARGB(255, 86, 152, 200),
                  Color.fromARGB(255, 100, 159, 217),
                  Color.fromARGB(255, 95, 167, 181),
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
                      _tr('app.quiz'),
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
                        color: Color(0xFF2E3A59),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
                        ),
                        borderRadius: BorderRadius.circular(15),
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
                    return LinearProgressIndicator(
                      value: _progressController.value,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                      minHeight: 8,
                    );
                  },
                ),
              ],
            ),
          ),

          // Question
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF6C63FF).withOpacity(0.1),
                  Colors.white,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
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
                  Icons.quiz,
                  color: Color(0xFF6C63FF),
                  size: 40,
                ),
                const SizedBox(height: 16),
                Text(
                  _tr(_questions[_currentQuestionIndex]['question']),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E3A59),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Réponses
          Column(
            children: List.generate(4, (index) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _selectAnswer(index),
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
                            color: _getAnswerColor(index).withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
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
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _tr(_questions[_currentQuestionIndex]['answers'][index]),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
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

          // Explication (si réponse sélectionnée)
          if (_showCorrectAnswer) ...[
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[50]!, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.blue[600], size: 24),
                      const SizedBox(width: 12),
                      Text(
                        _tr('quiz.explanation'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
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
                scoreColor.withOpacity(0.1),
                Colors.white,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: scoreColor.withOpacity(0.3)),
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
              Icon(
                percentage >= 80 ? Icons.emoji_events : 
                percentage >= 60 ? Icons.thumb_up : 
                percentage >= 40 ? Icons.school : Icons.refresh,
                color: scoreColor,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                _tr('quiz.result.title'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E3A59),
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
                  color: scoreColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Text(
                      '$_score / ${_questions.length}',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: scoreColor,
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
                  backgroundColor: const Color(0xFF6C63FF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Retour à l'accueil ou navigation
                  Navigator.of(context).pop();
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
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 100),
      ],
    );
  }
}