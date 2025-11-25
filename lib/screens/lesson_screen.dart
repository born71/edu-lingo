import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/progress_provider.dart';
import '../models/lesson.dart';
import '../models/quiz_question.dart';
import '../widgets/animated_widgets.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> with SingleTickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  bool _isAnswerChecked = false;
  String? _feedbackMessage;
  Color _feedbackColor = Colors.transparent;
  Lesson? _currentLesson;
  bool _isLoading = true;
  
  // Animation controllers
  late AnimationController _questionAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _questionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _questionAnimationController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _questionAnimationController, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _questionAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (_isLoading) {
      final lessonId = ModalRoute.of(context)?.settings.arguments as String?;
      final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
      
      if (lessonId != null) {
        _currentLesson = progressProvider.getLessonById(lessonId);
        // Start a new lesson session to reset progress counters
        if (_currentLesson != null) {
          progressProvider.startLessonSession(lessonId);
        }
      }
      
      // If no lesson ID provided, use the first available lesson
      if (_currentLesson == null) {
        if (progressProvider.lessons.isNotEmpty) {
          _currentLesson = progressProvider.lessons.first;
          // Start a new lesson session for the first lesson
          progressProvider.startLessonSession(_currentLesson!.id);
        }
      }
      
      setState(() {
        _isLoading = false;
      });
      
      // Start the question animation
      _questionAnimationController.forward();
    }
  }

  QuizQuestion get currentQuestion {
    if (_currentLesson == null || 
        _currentLesson!.questions.isEmpty || 
        _currentQuestionIndex >= _currentLesson!.questions.length ||
        _currentQuestionIndex < 0) {
      // Return a default question if no lesson is loaded or index is out of bounds
      return QuizQuestion(
        id: 'default',
        question: 'No questions available',
        correctAnswer: '',
        options: [],
      );
    }
    return _currentLesson!.questions[_currentQuestionIndex];
  }

  void _handleAnswer(String answer) {
    if (_isAnswerChecked) return;

    setState(() {
      _selectedAnswer = answer;
    });
  }

  void _checkAnswer() {
    if (_selectedAnswer == null) {
      _showSimpleMessage(
          'Please select an answer first.', Colors.orange.shade800);
      return;
    }

    final isCorrect = _selectedAnswer == currentQuestion.correctAnswer;
    
    // Record the answer in the progress provider
    final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
    progressProvider.recordAnswer(
      _currentLesson!.id,
      currentQuestion.id,
      _selectedAnswer!,
      isCorrect,
    );

    setState(() {
      _isAnswerChecked = true;
      if (isCorrect) {
        _feedbackMessage = 'Correct! Great job.';
        if (currentQuestion.explanation != null) {
          _feedbackMessage = _feedbackMessage! + '\n${currentQuestion.explanation!}';
        }
        _feedbackColor = Colors.green.shade600;
      } else {
        _feedbackMessage =
            'Incorrect. The correct answer was "${currentQuestion.correctAnswer}"';
        if (currentQuestion.explanation != null) {
          _feedbackMessage = _feedbackMessage! + '\n${currentQuestion.explanation!}';
        }
        _feedbackColor = Colors.red.shade600;
      }
    });
  }

  void _nextQuestion() {
    // Check if this is the last question before incrementing
    if (_currentQuestionIndex >= _currentLesson!.questions.length - 1) {
      _completeLesson();
      return;
    }

    // Animate out, then change question, then animate in
    _questionAnimationController.reverse().then((_) {
      setState(() {
        _isAnswerChecked = false;
        _selectedAnswer = null;
        _feedbackMessage = null;
        _feedbackColor = Colors.transparent;
        _currentQuestionIndex++;
      });
      _questionAnimationController.forward();
    });
  }

  void _completeLesson() {
    final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
    progressProvider.completeLesson(_currentLesson!.id);

    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
    final lessonProgress = progressProvider.getLessonProgress(_currentLesson!.id);
    final accuracy = lessonProgress?.accuracyPercentage ?? 0.0;
    final correctAnswers = lessonProgress?.correctAnswers ?? 0;
    final totalQuestions = _currentLesson!.questions.length;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Lesson Complete',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 600),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.elasticOut,
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.celebration, color: Colors.amber, size: 32),
            const SizedBox(width: 10),
            const Text('Lesson Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You finished "${_currentLesson!.title}"',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '$correctAnswers/$totalQuestions',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const Text('Correct'),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '${(accuracy * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const Text('Accuracy'),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '+${correctAnswers * 10 + 50}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    const Text('XP'),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to home
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showSimpleMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _currentLesson == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
          backgroundColor: const Color(0xFF1E1E2E),
          foregroundColor: Colors.white,
        ),
        backgroundColor: const Color(0xFF121212),
        body: const LoadingOverlay(message: 'Preparing lesson...'),
      );
    }

    if (_currentLesson!.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_currentLesson!.title),
          backgroundColor: const Color(0xFF1E1E2E),
          foregroundColor: Colors.white,
        ),
        backgroundColor: const Color(0xFF121212),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No questions available for this lesson.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    final double progress = (_currentQuestionIndex + 1) / _currentLesson!.questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(_currentLesson!.title),
        backgroundColor: const Color(0xFF1E1E2E),
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                '${_currentQuestionIndex + 1}/${_currentLesson!.questions.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // Progress Bar at the top
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade800,
                  color: Colors.deepPurple.shade300,
                  minHeight: 10,
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
                const SizedBox(height: 8),
                Consumer<ProgressProvider>(
                  builder: (context, progressProvider, child) {
                    final userProgress = progressProvider.userProgress;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Question ${_currentQuestionIndex + 1} of ${_currentLesson!.questions.length}',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                        Row(
                          children: [
                            Icon(Icons.stars, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${userProgress.totalXP} XP',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // Question Card with Animation
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // The main question text
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E2E),
                          borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (currentQuestion.language.isNotEmpty && currentQuestion.language != 'Mixed') ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.shade900,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              currentQuestion.language,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.purpleAccent.shade100,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        Text(
                          currentQuestion.question,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Option Buttons
                  ...currentQuestion.options.map((option) {
                    Color buttonColor = const Color(0xFF1E1E2E);
                    Color borderColor = Colors.grey.shade700;
                    Color textColor = Colors.white;

                    if (_isAnswerChecked) {
                      if (option == currentQuestion.correctAnswer) {
                        borderColor = Colors.green.shade400;
                        buttonColor = Colors.green.shade900;
                      } else if (option == _selectedAnswer) {
                        borderColor = Colors.red.shade400;
                        buttonColor = Colors.red.shade900;
                      }
                    } else if (option == _selectedAnswer) {
                      borderColor = Colors.deepPurple.shade300;
                      buttonColor = Colors.deepPurple.shade900;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: OutlinedButton(
                        onPressed: () => _handleAnswer(option),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: buttonColor,
                          side: BorderSide(color: borderColor, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Feedback and Action Bar (Bottom of Screen)
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: _isAnswerChecked ? _feedbackColor.withOpacity(0.9) : const Color(0xFF1E1E2E),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_feedbackMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        _feedbackMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                  ElevatedButton(
                    onPressed: _selectedAnswer == null && !_isAnswerChecked
                        ? null
                        : _isAnswerChecked
                            ? _nextQuestion
                            : _checkAnswer,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      backgroundColor: _isAnswerChecked
                          ? Colors.purple.shade400
                          : Colors.deepPurple.shade400,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: Text(
                      _isAnswerChecked ? 'CONTINUE' : 'CHECK ANSWER',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}