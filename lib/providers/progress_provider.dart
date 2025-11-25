import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_progress.dart';
import '../models/lesson.dart';
import '../models/quiz_question.dart';
import '../services/storage_service.dart';
import '../services/hybrid_storage_service.dart';
import '../services/lessons_api_service.dart';
// import '../services/api_service.dart';

class ProgressProvider extends ChangeNotifier {
  UserProgress _userProgress = UserProgress();
  List<Lesson> _lessons = [];
  bool _isLoading = false;
  String? _error;
  String _dataSource = 'unknown';

  // Getters
  UserProgress get userProgress => _userProgress;
  List<Lesson> get lessons => _lessons;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get dataSource => _dataSource;

  // Computed getters
  int get totalLessonsAvailable => _lessons.length;
  int get lessonsCompleted => _userProgress.totalLessonsCompleted;
  double get overallProgress => totalLessonsAvailable > 0 
      ? lessonsCompleted / totalLessonsAvailable 
      : 0.0;

  List<Lesson> get availableLessons {
    return _lessons.where((lesson) {
      final progress = _userProgress.getLessonProgress(lesson.id);
      return progress == null || !progress.isCompleted;
    }).toList();
  }

  List<Lesson> get completedLessons {
    return _lessons.where((lesson) {
      final progress = _userProgress.getLessonProgress(lesson.id);
      return progress != null && progress.isCompleted;
    }).toList();
  }

  // Initialize the provider
  Future<void> initialize() async {
    _setLoading(true);
    try {
      // Load user progress using hybrid storage
      final savedProgress = await HybridStorageService.loadUserProgress();
      if (savedProgress != null) {
        _userProgress = savedProgress;
      }

      // Load lessons using hybrid strategy
      await _loadOrCreateLessons();

      // Sync any offline data if possible
      await HybridStorageService.syncOfflineQueue();

      _clearError();
    } catch (e) {
      _setError('Failed to initialize: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load lessons using hybrid strategy (API + local cache)
  Future<void> _loadOrCreateLessons() async {
    try {
      print('\n🚀 [PROVIDER] Starting lesson loading process...');
      
      // Use HybridStorageService for seamless API + cache integration
      _lessons = await HybridStorageService.fetchLessons();
      
      // Determine data source based on the logging output
      // This is a simple way to track the source without modifying HybridStorageService return type
      _dataSource = await _determineDataSource();
      
      print('✅ [PROVIDER] Successfully loaded ${_lessons.length} lessons from $_dataSource');
    } catch (e) {
      print('🚨 [PROVIDER] Error loading lessons, using fallback: $e');
      // Final fallback to hardcoded lessons
      _lessons = _createDefaultLessons();
      _dataSource = 'fallback';
      print('⚠️ [PROVIDER] Using ${_lessons.length} fallback lessons due to error: $e');
    }
  }
  
  // Determine the data source based on service availability
  Future<String> _determineDataSource() async {
    try {
      // Check if we have recent cache
      final lastSync = await HybridStorageService.getLastSyncTime();
      final now = DateTime.now();
      
      // If synced in the last 5 minutes, likely from API
      if (lastSync != null && now.difference(lastSync).inMinutes < 5) {
        return 'api';
      }
      
      // Check if API is available now
      final isApiAvailable = await LessonsApiService.isServiceReachable();
      if (isApiAvailable) {
        return 'api';
      }
      
      // Check if we have any cached lessons
      final prefs = await SharedPreferences.getInstance();
      final cachedLessons = prefs.getString('lessons');
      if (cachedLessons != null) {
        return 'cache';
      }
      
      // Otherwise it's default/offline
      return 'default';
    } catch (e) {
      return 'unknownadfslk';
    }
  }

  // Create default lesson data
  List<Lesson> _createDefaultLessons() {
    // Import and use the lesson data from our data file
    return _getDefaultLessonsFromData();
  }

  List<Lesson> _getDefaultLessonsFromData() {
    return [
      Lesson(
        id: 'basic_greetings',
        title: 'Basic Greetings',
        description: 'Learn essential greetings in different languages',
        language: 'Multiple',
        difficulty: Difficulty.beginner,
        estimatedMinutes: 12,
        topics: ['greetings', 'basics', 'conversation'],
        questions: [
          QuizQuestion(
            id: 'greeting_1',
            question: 'Select the Spanish word for "Hello"',
            correctAnswer: 'Hola',
            options: ['Guten Tag', 'Bonjour', 'Hola', 'Ciao'],
            language: 'Spanish',
            difficulty: Difficulty.beginner,
            explanation: 'Hola is the most common and friendly way to say hello in Spanish.',
          ),
          QuizQuestion(
            id: 'greeting_2',
            question: 'How do you say "Thank you" in French?',
            correctAnswer: 'Merci',
            options: ['Danke', 'Merci', 'Gracias', 'Arigato'],
            language: 'French',
            difficulty: Difficulty.beginner,
            explanation: 'Merci is the standard way to say thank you in French.',
          ),
          QuizQuestion(
            id: 'greeting_3',
            question: 'What is the German word for "Water"?',
            correctAnswer: 'Wasser',
            options: ['Agua', 'Eau', 'Wasser', 'Mizu'],
            language: 'German',
            difficulty: Difficulty.beginner,
            explanation: 'Wasser is the German word for water, pronounced "VAH-ser".',
          ),
          QuizQuestion(
            id: 'greeting_4',
            question: 'How do you say "Good morning" in Spanish?',
            correctAnswer: 'Buenos días',
            options: ['Buenas noches', 'Buenos días', 'Buenas tardes', 'Hasta luego'],
            language: 'Spanish',
            difficulty: Difficulty.beginner,
            explanation: 'Buenos días means "good morning" in Spanish, used until noon.',
          ),
          QuizQuestion(
            id: 'greeting_5',
            question: 'What does "Au revoir" mean in French?',
            correctAnswer: 'Goodbye',
            options: ['Hello', 'Thank you', 'Goodbye', 'Please'],
            language: 'French',
            difficulty: Difficulty.beginner,
            explanation: 'Au revoir is a formal way to say goodbye in French.',
          ),
        ],
      ),
      Lesson(
        id: 'spanish_numbers_1_10',
        title: 'Spanish Numbers 1-10',
        description: 'Master counting from 1 to 10 in Spanish',
        language: 'Spanish',
        difficulty: Difficulty.beginner,
        estimatedMinutes: 15,
        topics: ['numbers', 'counting', 'mathematics'],
        questions: [
          QuizQuestion(
            id: 'number_1',
            question: 'How do you say "One" in Spanish?',
            correctAnswer: 'Uno',
            options: ['Dos', 'Uno', 'Tres', 'Cuatro'],
            language: 'Spanish',
            difficulty: Difficulty.beginner,
            explanation: 'Uno is "one" in Spanish, pronounced "OO-no".',
          ),
          QuizQuestion(
            id: 'number_2',
            question: 'What is "Five" in Spanish?',
            correctAnswer: 'Cinco',
            options: ['Cuatro', 'Cinco', 'Seis', 'Siete'],
            language: 'Spanish',
            difficulty: Difficulty.beginner,
            explanation: 'Cinco means "five" in Spanish, pronounced "SEEN-ko".',
          ),
          QuizQuestion(
            id: 'number_3',
            question: 'How do you say "Ten" in Spanish?',
            correctAnswer: 'Diez',
            options: ['Nueve', 'Ocho', 'Diez', 'Once'],
            language: 'Spanish',
            difficulty: Difficulty.beginner,
            explanation: 'Diez means "ten" in Spanish, pronounced "dee-ESS".',
          ),
          QuizQuestion(
            id: 'number_4',
            question: 'What number is "Siete"?',
            correctAnswer: 'Seven',
            options: ['Six', 'Seven', 'Eight', 'Nine'],
            language: 'Spanish',
            difficulty: Difficulty.beginner,
            explanation: 'Siete means "seven" in Spanish.',
          ),
          QuizQuestion(
            id: 'number_5',
            question: 'Which number comes after "Tres"?',
            correctAnswer: 'Cuatro',
            options: ['Dos', 'Cuatro', 'Cinco', 'Seis'],
            language: 'Spanish',
            difficulty: Difficulty.beginner,
            explanation: 'After tres (three) comes cuatro (four).',
          ),
        ],
      ),
      Lesson(
        id: 'french_colors',
        title: 'French Colors',
        description: 'Learn basic colors in French',
        language: 'French',
        difficulty: Difficulty.beginner,
        estimatedMinutes: 12,
        topics: ['colors', 'vocabulary', 'adjectives'],
        questions: [
          QuizQuestion(
            id: 'color_1',
            question: 'How do you say "Red" in French?',
            correctAnswer: 'Rouge',
            options: ['Bleu', 'Vert', 'Rouge', 'Jaune'],
            language: 'French',
            difficulty: Difficulty.beginner,
            explanation: 'Rouge means "red" in French, pronounced "roozh".',
          ),
          QuizQuestion(
            id: 'color_2',
            question: 'What is "Blue" in French?',
            correctAnswer: 'Bleu',
            options: ['Rouge', 'Bleu', 'Noir', 'Blanc'],
            language: 'French',
            difficulty: Difficulty.beginner,
            explanation: 'Bleu means "blue" in French, pronounced "bluh".',
          ),
          QuizQuestion(
            id: 'color_3',
            question: 'How do you say "Green" in French?',
            correctAnswer: 'Vert',
            options: ['Violet', 'Vert', 'Orange', 'Rose'],
            language: 'French',
            difficulty: Difficulty.beginner,
            explanation: 'Vert means "green" in French, pronounced "vair".',
          ),
          QuizQuestion(
            id: 'color_4',
            question: 'What color is "Jaune"?',
            correctAnswer: 'Yellow',
            options: ['Orange', 'Yellow', 'Purple', 'Pink'],
            language: 'French',
            difficulty: Difficulty.beginner,
            explanation: 'Jaune means "yellow" in French.',
          ),
        ],
      ),
    ];
  }

  // Record answer for a question
  Future<void> recordAnswer(String lessonId, String questionId, 
      String selectedAnswer, bool isCorrect) async {
    try {
      final now = DateTime.now();
      
      // Get or create lesson progress
      final currentProgress = _userProgress.getLessonProgress(lessonId) ?? 
          LessonProgress(
            lessonId: lessonId,
            totalQuestions: getLessonById(lessonId)?.totalQuestions ?? 0,
          );

      // Update progress
      final updatedProgress = currentProgress.copyWith(
        questionsCompleted: currentProgress.questionsCompleted + 1,
        correctAnswers: isCorrect 
            ? currentProgress.correctAnswers + 1 
            : currentProgress.correctAnswers,
        incorrectAnswerIds: isCorrect 
            ? currentProgress.incorrectAnswerIds
            : [...currentProgress.incorrectAnswerIds, questionId],
        lastCompletedAt: now,
      );

      // Update user progress
      final updatedLessonProgress = Map<String, LessonProgress>.from(_userProgress.lessonProgress);
      updatedLessonProgress[lessonId] = updatedProgress;

      _userProgress = _userProgress.copyWith(
        lessonProgress: updatedLessonProgress,
        totalQuestionsAnswered: _userProgress.totalQuestionsAnswered + 1,
        totalCorrectAnswers: isCorrect 
            ? _userProgress.totalCorrectAnswers + 1 
            : _userProgress.totalCorrectAnswers,
        totalXP: _userProgress.totalXP + (isCorrect ? 10 : 5), // XP rewards
        lastStudyDate: now,
      );

      await _saveProgress();
      notifyListeners();
    } catch (e) {
      _setError('Failed to record answer: $e');
    }
  }

  // Complete a lesson
  Future<void> completeLesson(String lessonId) async {
    try {
      final currentProgress = _userProgress.getLessonProgress(lessonId);
      if (currentProgress == null) return;

      final completedProgress = currentProgress.copyWith(
        isCompleted: true,
        attemptCount: currentProgress.attemptCount + 1,
      );

      final updatedLessonProgress = Map<String, LessonProgress>.from(_userProgress.lessonProgress);
      updatedLessonProgress[lessonId] = completedProgress;

      // Update streak
      final newStreak = await _calculateNewStreak();

      _userProgress = _userProgress.copyWith(
        lessonProgress: updatedLessonProgress,
        totalLessonsCompleted: _userProgress.totalLessonsCompleted + 1,
        currentStreak: newStreak,
        totalXP: _userProgress.totalXP + 50, // Bonus XP for completing lesson
      );

      await _saveProgress();
      notifyListeners();
    } catch (e) {
      _setError('Failed to complete lesson: $e');
    }
  }

  // Calculate new streak
  Future<int> _calculateNewStreak() async {
    return await StorageService.calculateStreak(_userProgress.lastStudyDate);
  }

  // Get lesson by ID
  Lesson? getLessonById(String lessonId) {
    try {
      return _lessons.firstWhere((lesson) => lesson.id == lessonId);
    } catch (e) {
      return null;
    }
  }

  // Get lesson progress
  LessonProgress? getLessonProgress(String lessonId) {
    return _userProgress.getLessonProgress(lessonId);
  }

  // Start a new lesson session (resets the current session progress)
  Future<void> startLessonSession(String lessonId) async {
    try {
      final lesson = getLessonById(lessonId);
      if (lesson == null) return;

      // Create a fresh lesson progress for this session
      final sessionProgress = LessonProgress(
        lessonId: lessonId,
        totalQuestions: lesson.totalQuestions,
        questionsCompleted: 0,
        correctAnswers: 0,
        incorrectAnswerIds: [],
        isCompleted: false,
        attemptCount: _userProgress.getLessonProgress(lessonId)?.attemptCount ?? 0,
      );

      final updatedLessonProgress = Map<String, LessonProgress>.from(_userProgress.lessonProgress);
      updatedLessonProgress[lessonId] = sessionProgress;

      _userProgress = _userProgress.copyWith(
        lessonProgress: updatedLessonProgress,
      );

      await _saveProgress();
      notifyListeners();
    } catch (e) {
      _setError('Failed to start lesson session: $e');
    }
  }

  // Reset progress for a lesson
  Future<void> resetLessonProgress(String lessonId) async {
    try {
      final updatedLessonProgress = Map<String, LessonProgress>.from(_userProgress.lessonProgress);
      updatedLessonProgress.remove(lessonId);

      _userProgress = _userProgress.copyWith(
        lessonProgress: updatedLessonProgress,
      );

      await _saveProgress();
      notifyListeners();
    } catch (e) {
      _setError('Failed to reset lesson progress: $e');
    }
  }

  // Reset all progress
  Future<void> resetAllProgress() async {
    try {
      _userProgress = UserProgress();
      await StorageService.clearAllData();
      notifyListeners();
    } catch (e) {
      _setError('Failed to reset all progress: $e');
    }
  }

  // Private methods
  Future<void> _saveProgress() async {
    await HybridStorageService.saveUserProgress(_userProgress);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Update user preferences
  Future<void> updatePreferredLanguage(String language) async {
    try {
      _userProgress = _userProgress.copyWith(preferredLanguage: language);
      await _saveProgress();
      notifyListeners();
    } catch (e) {
      _setError('Failed to update preferred language: $e');
    }
  }

  Future<void> updateDailyGoal(int minutes) async {
    try {
      _userProgress = _userProgress.copyWith(dailyGoal: minutes);
      await _saveProgress();
      notifyListeners();
    } catch (e) {
      _setError('Failed to update daily goal: $e');
    }
  }
}