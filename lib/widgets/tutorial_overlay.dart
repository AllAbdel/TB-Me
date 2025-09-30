// ===== lib/widgets/tutorial_overlay.dart =====
import 'package:flutter/material.dart';
import 'dart:io';
import '../providers/language_provider.dart';

class TutorialOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const TutorialOverlay({super.key, required this.onComplete});

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  final LanguageProvider _languageProvider = LanguageProvider();
  int _currentStep = 0;
  
  String _tr(String key) => _languageProvider.translate(key);

  final List<TutorialStep> _steps = [
    TutorialStep(
      targetKey: 'welcome',
      position: TutorialPosition.center,
    ),
    TutorialStep(
      targetKey: 'dashboard_tile',
      position: TutorialPosition.topLeft,
    ),
    TutorialStep(
      targetKey: 'medications_tile',
      position: TutorialPosition.topRight,
    ),
    TutorialStep(
      targetKey: 'calendar_tile',
      position: TutorialPosition.bottomLeft,
    ),
    TutorialStep(
      targetKey: 'history_tile',
      position: TutorialPosition.bottomRight,
    ),
    TutorialStep(
      targetKey: 'security',
      position: TutorialPosition.center,
    ),
  ];

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      widget.onComplete();
    }
  }

  void _skipTutorial() {
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.85),
      child: Stack(
        children: [
          // Zone cliquable pour passer
          Positioned.fill(
            child: GestureDetector(
              onTap: _nextStep,
              child: Container(color: Colors.transparent),
            ),
          ),

          // Bulle de dialogue
          _buildTutorialBubble(),

          // Bouton Passer
          Positioned(
            top: 40,
            right: 20,
            child: TextButton(
              onPressed: _skipTutorial,
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                _tr('tutorial.skip'),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),

          // Indicateur de progression
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _steps.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentStep
                        ? Colors.white
                        : Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialBubble() {
  final step = _steps[_currentStep];
  
  Widget content;
  switch (step.targetKey) {
    case 'welcome':
      content = _buildWelcomeContent();
      break;
    case 'dashboard_tile':
      content = _buildDashboardContent();
      break;
    case 'medications_tile':
      content = _buildMedicationsContent();
      break;
    case 'calendar_tile':
      content = _buildCalendarContent();
      break;
    case 'history_tile':
      content = _buildHistoryContent();
      break;
    case 'security':
      content = _buildSecurityContent();
      break;
    default:
      content = Container();
  }

  // Position adaptative selon l'étape
  bool isBottomTile = step.position == TutorialPosition.bottomLeft || 
                      step.position == TutorialPosition.bottomRight;

  return Align(
    alignment: isBottomTile ? Alignment.topCenter : Alignment.center,
    child: SingleChildScrollView( // AJOUT DU SCROLLVIEW
      child: Container(
        margin: EdgeInsets.only(
          top: isBottomTile ? 100 : 150,
          left: 20,
          right: 20,
          bottom: 20,
        ),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Flèche indicative pour les tuiles du bas
            if (isBottomTile) ...[
              Icon(Icons.arrow_downward, color: Colors.orange, size: 40),
              SizedBox(height: 8),
              Text(
                _tr('tutorial.scroll_hint'),
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 12),
            ],
            content,
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                _currentStep < _steps.length - 1
                    ? _tr('tutorial.next')
                    : _tr('tutorial.finish'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildWelcomeContent() {
    return Column(
      children: [
        const Icon(Icons.waving_hand, size: 60, color: Color(0xFF1565C0)),
        const SizedBox(height: 16),
        Text(
          _tr('tutorial.welcome_title'),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E3A59),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          _tr('tutorial.welcome_message'),
          style: const TextStyle(fontSize: 16, color: Colors.black87),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDashboardContent() {
    return Column(
      children: [
        const Icon(Icons.dashboard, size: 50, color: Color(0xFF4CAF50)),
        const SizedBox(height: 12),
        Text(
          _tr('tutorial.dashboard_title'),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _tr('tutorial.dashboard_description'),
          style: const TextStyle(fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMedicationsContent() {
    return Column(
      children: [
        const Icon(Icons.medication, size: 50, color: Color(0xFF2196F3)),
        const SizedBox(height: 12),
        Text(
          _tr('tutorial.medications_title'),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _tr('tutorial.medications_description'),
          style: const TextStyle(fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCalendarContent() {
    return Column(
      children: [
        const Icon(Icons.calendar_today, size: 50, color: Color(0xFF009688)),
        const SizedBox(height: 12),
        Text(
          _tr('tutorial.calendar_title'),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _tr('tutorial.calendar_description'),
          style: const TextStyle(fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHistoryContent() {
    return Column(
      children: [
        const Icon(Icons.history, size: 50, color: Color(0xFF9C27B0)),
        const SizedBox(height: 12),
        Text(
          _tr('tutorial.history_title'),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _tr('tutorial.history_description'),
          style: const TextStyle(fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSecurityContent() {
    final isIOS = Platform.isIOS;
    
    return SingleChildScrollView(
      child: Column(
        children: [
          const Icon(Icons.security, size: 50, color: Color(0xFFFF9800)),
          const SizedBox(height: 12),
          Text(
            _tr('tutorial.security_title'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _tr('tutorial.security_intro'),
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isIOS ? Icons.apple : Icons.android,
                      color: Colors.blue[700],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isIOS ? _tr('tutorial.ios') : _tr('tutorial.android'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (isIOS) ...[
                  Text(_tr('tutorial.ios_step1'), style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(_tr('tutorial.ios_step2'), style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(_tr('tutorial.ios_step3'), style: const TextStyle(fontSize: 13)),
                ] else ...[
                  Text(_tr('tutorial.android_step1'), style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(_tr('tutorial.android_step2'), style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(_tr('tutorial.android_step3'), style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(_tr('tutorial.android_step4'), style: const TextStyle(fontSize: 13)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TutorialStep {
  final String targetKey;
  final TutorialPosition position;

  TutorialStep({
    required this.targetKey,
    required this.position,
  });
}

enum TutorialPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  center,
}