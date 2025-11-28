import 'package:flutter/foundation.dart';
import '../models/user_progress.dart';
import '../models/lesson.dart';
import '../services/storage_service.dart';
import '../services/hybrid_storage_service.dart';
import '../services/lessons_api_service.dart';
import '../data/lesson_data.dart';
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

  // Load lessons from API service directly, then fallback to local data
  Future<void> _loadOrCreateLessons() async {
    print('🚀 [PROVIDER] Starting to load lessons...');
    
    // First try: Direct API call
    try {
      print('🌐 [PROVIDER] Attempting to fetch from API...');
      final apiLessons = await LessonsApiService.fetchLessons();
      
      if (apiLessons.isNotEmpty) {
        _lessons = apiLessons;
        _dataSource = 'api';
        print('✅ [PROVIDER] Loaded ${apiLessons.length} lessons from API');
        print('📋 [PROVIDER] Lessons: ${apiLessons.map((l) => l.title).join(', ')}');
        return;
      } else {
        print('⚠️ [PROVIDER] API returned empty list');
      }
    } catch (e) {
      print('❌ [PROVIDER] API fetch failed: $e');
    }
    
    // Second try: Local lesson data from lesson_data.dart
    try {
      print('📄 [PROVIDER] Falling back to local data...');
      _lessons = LessonData.getDefaultLessons();
      _dataSource = 'local';
      print('✅ [PROVIDER] Loaded ${_lessons.length} lessons from local data');
    } catch (e) {
      print('💥 [PROVIDER] Critical error: $e');
      _lessons = [];
      _dataSource = 'error';
      throw Exception('Failed to load lessons from both API and local data: $e');
    }
  }

  // Refresh lessons from API (can be called manually)
  Future<void> refreshLessonsFromApi() async {
    _setLoading(true);
    try {
      print('🔄 [PROVIDER] Refreshing lessons from API...');
      final apiLessons = await LessonsApiService.fetchLessons();
      
      if (apiLessons.isNotEmpty) {
        _lessons = apiLessons;
        _dataSource = 'api';
        print('✅ [PROVIDER] Refreshed ${apiLessons.length} lessons from API');
        notifyListeners();
      } else {
        print('⚠️ [PROVIDER] API returned empty list, keeping current lessons');
      }
    } catch (e) {
      print('❌ [PROVIDER] Refresh failed: $e');
      _setError('Failed to refresh lessons: $e');
    } finally {
      _setLoading(false);
    }
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

  // Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? email,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      _userProgress = _userProgress.copyWith(
        displayName: displayName,
        email: email,
        bio: bio,
        avatarUrl: avatarUrl,
      );
      await _saveProgress();
      notifyListeners();
    } catch (e) {
      _setError('Failed to update profile: $e');
      rethrow;
    }
  }
}