import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_progress.dart';
import '../models/lesson.dart';
import '../data/lesson_data.dart';
import 'lessons_api_service.dart';

class HybridStorageService {
  static const String _userProgressKey = 'user_progress';
  static const String _lessonsKey = 'lessons';
  static const String _userIdKey = 'user_id';
  static const String _lastSyncKey = 'last_sync';
  static const String _offlineQueueKey = 'offline_queue';

  static SharedPreferences? _prefs;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<SharedPreferences> get _preferences async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  // ===== USER MANAGEMENT =====
  
  static Future<void> saveUserId(String userId) async {
    final prefs = await _preferences;
    await prefs.setString(_userIdKey, userId);
  }
  
  static Future<String?> getUserId() async {
    final prefs = await _preferences;
    return prefs.getString(_userIdKey);
  }

  // ===== HYBRID LESSON MANAGEMENT =====
  
  /// Fetch lessons with fallback strategy:
  /// 1. Try to fetch from Lessons microservice
  /// 2. If offline, use cached lessons
  /// 3. If no cache, use default lessons
  static Future<List<Lesson>> fetchLessons({
    String? language,
    String? difficulty,
    bool forceRefresh = false,
  }) async {
    print('\n🚀 [HYBRID] Starting lesson fetch...');
    print('🔍 [HYBRID] Params: language=$language, difficulty=$difficulty, forceRefresh=$forceRefresh');
    
    try {
      // Check if we should try Lessons API first
      print('🌐 [HYBRID] Checking if API is reachable...');
      final isReachable = await LessonsApiService.isServiceReachable();
      print('📡 [HYBRID] API reachable: $isReachable');
      
      if (isReachable || forceRefresh) {
        print('✅ [HYBRID] Fetching from API...');
        
        final apiLessons = await LessonsApiService.fetchLessons(
          language: language,
          difficulty: difficulty,
        );
        
        print('📦 [HYBRID] Got ${apiLessons.length} lessons from API');
        
        // Cache the lessons locally
        await _cacheLessons(apiLessons);
        await _updateLastSync();
        
        print('💾 [HYBRID] Cached ${apiLessons.length} lessons locally');
        return apiLessons;
      } else {
        print('⚠️ [HYBRID] API not reachable, using fallback...');
      }
    } catch (e) {
      print('❌ [HYBRID] API error: $e');
      // Fall through to cached/local lessons
    }
    
    // Fallback to cached lessons
    print('💾 [HYBRID] Trying cached lessons...');
    final cachedLessons = await _loadCachedLessons();
    if (cachedLessons.isNotEmpty) {
      print('✅ [HYBRID] Found ${cachedLessons.length} cached lessons');
      return cachedLessons;
    }
    
    // Final fallback to default lessons
    print('📜 [HYBRID] Using default lessons...');
    final defaultLessons = _getDefaultLessons();
    print('✅ [HYBRID] Loaded ${defaultLessons.length} default lessons');
    return defaultLessons;
  }
  
  static Future<void> _cacheLessons(List<Lesson> lessons) async {
    try {
      final prefs = await _preferences;
      final jsonString = jsonEncode(lessons.map((l) => l.toJson()).toList());
      await prefs.setString(_lessonsKey, jsonString);
    } catch (e) {
    }
  }
  
  static Future<List<Lesson>> _loadCachedLessons() async {
    try {
      final prefs = await _preferences;
      final jsonString = prefs.getString(_lessonsKey);
      
      if (jsonString != null) {
        final jsonList = jsonDecode(jsonString) as List;
        return jsonList.map((json) => Lesson.fromJson(json)).toList();
      }
    } catch (e) {
      // Silent fail for cache loading
    }
    
    return [];
  }

  // ===== HYBRID PROGRESS MANAGEMENT =====
  
  /// Save progress with auto-sync to server
  static Future<bool> saveUserProgress(UserProgress progress) async {
    try {
      // Always save locally first
      final prefs = await _preferences;
      final jsonString = jsonEncode(progress.toJson());
      await prefs.setString(_userProgressKey, jsonString);
      
      // TODO: Sync to User Progress microservice when ready
      // For now, just save locally and queue for future sync
      final userId = await getUserId();
      if (userId != null) {
        // Queue for later sync when user progress service is available
        await _queueOfflineAction('sync_progress', progress.toJson());
      }
      return true; // Local save successful
    } catch (e) {
      return false;
    }
  }
  
  /// Load progress with server sync
  static Future<UserProgress?> loadUserProgress() async {
    try {
      // TODO: Fetch from User Progress microservice when ready
      // Fallback to local cache
      return await _loadProgressLocally();
    } catch (e) {
      return null;
    }
  }
  
  static Future<UserProgress?> _loadProgressLocally() async {
    try {
      final prefs = await _preferences;
      final jsonString = prefs.getString(_userProgressKey);
      
      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return UserProgress.fromJson(json);
      }
    } catch (e) {
    }
    
    return null;
  }

  // ===== OFFLINE QUEUE MANAGEMENT =====
  
  static Future<void> _queueOfflineAction(String action, Map<String, dynamic> data) async {
    try {
      final prefs = await _preferences;
      final queueJson = prefs.getString(_offlineQueueKey) ?? '[]';
      final List<dynamic> queue = jsonDecode(queueJson);
      
      queue.add({
        'action': action,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      await prefs.setString(_offlineQueueKey, jsonEncode(queue));
    } catch (e) {
      // Silent fail for offline queue
    }
  }
  
  /// Process queued offline actions when connection is restored
  static Future<void> syncOfflineQueue() async {
    // TODO: Implement when microservices are ready
  }

  // ===== SYNC MANAGEMENT =====
  
  static Future<void> _updateLastSync() async {
    final prefs = await _preferences;
    await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
  }
  
  static Future<DateTime?> getLastSyncTime() async {
    try {
      final prefs = await _preferences;
      final syncTime = prefs.getString(_lastSyncKey);
      return syncTime != null ? DateTime.parse(syncTime) : null;
    } catch (e) {
      return null;
    }
  }
  
  /// Force sync all data with server
  static Future<bool> forceSyncAll() async {
    try {
      // TODO: Implement when User Progress microservice is ready
      
      // For now, just sync offline queue (log only)
      await syncOfflineQueue();
      
      return true; // Return success for local operations
    } catch (e) {
      return false;
    }
  }

  // ===== ANSWER RECORDING =====
  
  /// Record answer with offline support
  static Future<bool> recordAnswer({
    required String lessonId,
    required String questionId,
    required String selectedAnswer,
    required bool isCorrect,
  }) async {
    try {
      final userId = await getUserId();
      final timestamp = DateTime.now();
      
      // TODO: Send to User Progress microservice when ready
      // For now, just queue for future sync
      if (userId != null) {
        await _queueOfflineAction('record_answer', {
          'lessonId': lessonId,
          'questionId': questionId,
          'selectedAnswer': selectedAnswer,
          'isCorrect': isCorrect,
          'timestamp': timestamp.toIso8601String(),
        });
      }
      return true; // Always return success for local storage
    } catch (e) {
      return false;
    }
  }

  // ===== DEFAULT LESSONS (Fallback) =====
  
  static List<Lesson> _getDefaultLessons() {
    // Return your current static lessons as fallback
    final lessons = LessonData.getDefaultLessons();
    return lessons;
  }

  // ===== CLEANUP =====
  
  static Future<bool> clearAllData() async {
    try {
      final prefs = await _preferences;
      await prefs.clear();
      return true;
    } catch (e) {
      return false;
    }
  }
}