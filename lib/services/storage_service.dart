import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_progress.dart';
import '../models/lesson.dart';

class StorageService {
  static const String _userProgressKey = 'user_progress';
  static const String _lessonsKey = 'lessons';
  static const String _completedLessonsKey = 'completed_lessons';

  static SharedPreferences? _prefs;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Ensure preferences are initialized
  static Future<SharedPreferences> get _preferences async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  // Save user progress
  static Future<bool> saveUserProgress(UserProgress progress) async {
    try {
      final prefs = await _preferences;
      final jsonString = jsonEncode(progress.toJson());
      return await prefs.setString(_userProgressKey, jsonString);
    } catch (e) {
      print('Error saving user progress: $e');
      return false;
    }
  }

  // Load user progress
  static Future<UserProgress?> loadUserProgress() async {
    try {
      final prefs = await _preferences;
      final jsonString = prefs.getString(_userProgressKey);
      
      if (jsonString == null) {
        return null;
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserProgress.fromJson(json);
    } catch (e) {
      print('Error loading user progress: $e');
      return null;
    }
  }

  // Save lessons data
  static Future<bool> saveLessons(List<Lesson> lessons) async {
    try {
      final prefs = await _preferences;
      final jsonString = jsonEncode(lessons.map((l) => l.toJson()).toList());
      return await prefs.setString(_lessonsKey, jsonString);
    } catch (e) {
      print('Error saving lessons: $e');
      return false;
    }
  }

  // Load lessons data
  static Future<List<Lesson>> loadLessons() async {
    try {
      final prefs = await _preferences;
      final jsonString = prefs.getString(_lessonsKey);
      
      if (jsonString == null) {
        return [];
      }

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => Lesson.fromJson(json)).toList();
    } catch (e) {
      print('Error loading lessons: $e');
      return [];
    }
  }

  // Save completed lesson IDs
  static Future<bool> saveCompletedLessons(List<String> completedLessonIds) async {
    try {
      final prefs = await _preferences;
      return await prefs.setStringList(_completedLessonsKey, completedLessonIds);
    } catch (e) {
      print('Error saving completed lessons: $e');
      return false;
    }
  }

  // Load completed lesson IDs
  static Future<List<String>> loadCompletedLessons() async {
    try {
      final prefs = await _preferences;
      return prefs.getStringList(_completedLessonsKey) ?? [];
    } catch (e) {
      print('Error loading completed lessons: $e');
      return [];
    }
  }

  // Clear all data (for testing or reset)
  static Future<bool> clearAllData() async {
    try {
      final prefs = await _preferences;
      await prefs.remove(_userProgressKey);
      await prefs.remove(_lessonsKey);
      await prefs.remove(_completedLessonsKey);
      return true;
    } catch (e) {
      print('Error clearing data: $e');
      return false;
    }
  }

  // Update streak based on last study date
  static Future<int> calculateStreak(DateTime? lastStudyDate) async {
    if (lastStudyDate == null) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final lastStudy = DateTime(
      lastStudyDate.year, 
      lastStudyDate.month, 
      lastStudyDate.day
    );

    if (lastStudy == today || lastStudy == yesterday) {
      // Continue or maintain streak
      return await _getCurrentStreak() + (lastStudy == yesterday ? 1 : 0);
    } else {
      // Streak is broken, reset to 0 or 1 if studied today
      return lastStudy == today ? 1 : 0;
    }
  }

  // Helper to get current streak from storage
  static Future<int> _getCurrentStreak() async {
    final progress = await loadUserProgress();
    return progress?.currentStreak ?? 0;
  }

  // Save individual setting
  static Future<bool> saveSetting(String key, dynamic value) async {
    try {
      final prefs = await _preferences;
      
      if (value is String) {
        return await prefs.setString(key, value);
      } else if (value is int) {
        return await prefs.setInt(key, value);
      } else if (value is bool) {
        return await prefs.setBool(key, value);
      } else if (value is double) {
        return await prefs.setDouble(key, value);
      } else {
        // For complex objects, use JSON
        return await prefs.setString(key, jsonEncode(value));
      }
    } catch (e) {
      print('Error saving setting $key: $e');
      return false;
    }
  }

  // Load individual setting
  static Future<T?> loadSetting<T>(String key) async {
    try {
      final prefs = await _preferences;
      final value = prefs.get(key);
      
      if (value is T) {
        return value;
      } else if (value is String && T != String) {
        // Try to decode JSON for complex objects
        try {
          return jsonDecode(value) as T;
        } catch (_) {
          return null;
        }
      }
      
      return null;
    } catch (e) {
      print('Error loading setting $key: $e');
      return null;
    }
  }
}