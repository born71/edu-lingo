import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/lesson.dart';

/// Service for communicating with the Lessons microservice
class LessonsApiService {
  static const Duration _timeout = AppConfig.apiTimeout;

  /// Check if lessons service is reachable
  static Future<bool> isServiceReachable() async {
    try {
      final url = AppConfig.buildLessonsEndpoint('lessons');
      print('🔍 [API] Checking lessons service health: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_timeout);
      
      final isReachable = response.statusCode == 200;
      print('✅ [API] Lessons service ${isReachable ? 'ONLINE' : 'OFFLINE'} (Status: ${response.statusCode})');
      
      return isReachable;
    } catch (e) {
      print('❌ [API] Lessons service health check failed: $e');
      return false;
    }
  }

  /// Fetch all lessons from the service
  static Future<List<Lesson>> fetchLessons({
    String? language,
    String? difficulty,
  }) async {
    try {
      String url;
      String filterInfo = '';
      
      if (language != null) {
        url = AppConfig.buildLessonsEndpoint('lessonsByLanguage', {'language': language});
        filterInfo = ' (filtered by language: $language)';
      } else if (difficulty != null) {
        url = AppConfig.buildLessonsEndpoint('lessonsByDifficulty', {'difficulty': difficulty});
        filterInfo = ' (filtered by difficulty: $difficulty)';
      } else {
        url = AppConfig.buildLessonsEndpoint('lessons');
        filterInfo = ' (all lessons)';
      }

      print('🌐 [API] Fetching lessons from microservice$filterInfo');
      print('📡 [API] Request URL: $url');
      
      final stopwatch = Stopwatch()..start();
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (AppConfig.apiKey.isNotEmpty) 'Authorization': 'Bearer ${AppConfig.apiKey}',
        },
      ).timeout(_timeout);
      stopwatch.stop();

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final lessons = jsonList.map((json) => Lesson.fromJson(json)).toList();
        
        print('✅ [API] Successfully fetched ${lessons.length} lessons from API in ${stopwatch.elapsedMilliseconds}ms');
        print('📋 [API] Lessons received: ${lessons.map((l) => l.title).join(', ')}');
        
        return lessons;
      } else {
        print('❌ [API] Failed to fetch lessons: ${response.statusCode} ${response.reasonPhrase}');
        throw Exception('Failed to fetch lessons: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('💥 [API] Error fetching lessons from microservice: $e');
      rethrow;
    }
  }

  /// Fetch a specific lesson by ID
  static Future<Lesson?> fetchLessonById(String lessonId) async {
    try {
      final url = AppConfig.buildLessonsEndpoint('lessonById', {'id': lessonId});

      print('🔍 [API] Fetching specific lesson: $lessonId');
      print('📡 [API] Request URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (AppConfig.apiKey.isNotEmpty) 'Authorization': 'Bearer ${AppConfig.apiKey}',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final lesson = Lesson.fromJson(json);
        print('✅ [API] Successfully fetched lesson "${lesson.title}" from API');
        return lesson;
      } else if (response.statusCode == 404) {
        print('❌ [API] Lesson not found: $lessonId');
        return null; // Lesson not found
      } else {
        print('❌ [API] Failed to fetch lesson: ${response.statusCode} ${response.reasonPhrase}');
        throw Exception('Failed to fetch lesson: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('💥 [API] Error fetching lesson by ID: $e');
      rethrow;
    }
  }

  /// Search lessons by query
  static Future<List<Lesson>> searchLessons(String query) async {
    try {
      final url = AppConfig.buildLessonsEndpoint('searchLessons');
      
      final response = await http.get(
        Uri.parse('$url?q=${Uri.encodeComponent(query)}'),
        headers: {
          'Content-Type': 'application/json',
          if (AppConfig.apiKey.isNotEmpty) 'Authorization': 'Bearer ${AppConfig.apiKey}',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Lesson.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search lessons: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error searching lessons: $e');
      rethrow;
    }
  }

  /// Create a new lesson (Admin functionality)
  static Future<Lesson?> createLesson(Lesson lesson) async {
    try {
      final url = AppConfig.buildLessonsEndpoint('createLesson');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (AppConfig.apiKey.isNotEmpty) 'Authorization': 'Bearer ${AppConfig.apiKey}',
        },
        body: jsonEncode(lesson.toJson()),
      ).timeout(_timeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return Lesson.fromJson(json);
      } else {
        throw Exception('Failed to create lesson: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error creating lesson: $e');
      rethrow;
    }
  }

  /// Update an existing lesson (Admin functionality)
  static Future<Lesson?> updateLesson(String lessonId, Lesson lesson) async {
    try {
      final url = AppConfig.buildLessonsEndpoint('updateLesson', {'id': lessonId});

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (AppConfig.apiKey.isNotEmpty) 'Authorization': 'Bearer ${AppConfig.apiKey}',
        },
        body: jsonEncode(lesson.toJson()),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return Lesson.fromJson(json);
      } else {
        throw Exception('Failed to update lesson: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error updating lesson: $e');
      rethrow;
    }
  }

  /// Delete a lesson (Admin functionality)
  static Future<bool> deleteLesson(String lessonId) async {
    try {
      final url = AppConfig.buildLessonsEndpoint('deleteLesson', {'id': lessonId});

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (AppConfig.apiKey.isNotEmpty) 'Authorization': 'Bearer ${AppConfig.apiKey}',
        },
      ).timeout(_timeout);

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error deleting lesson: $e');
      return false;
    }
  }

  /// Get lessons with questions included
  static Future<List<Lesson>> fetchLessonsWithQuestions({
    String? language,
    String? difficulty,
  }) async {
    try {
      final lessons = await fetchLessons(language: language, difficulty: difficulty);
      
      // For each lesson, if questions are not included, fetch them separately
      for (int i = 0; i < lessons.length; i++) {
        if (lessons[i].questions.isEmpty) {
          final questionsUrl = AppConfig.buildLessonsEndpoint(
            'lessonQuestions', 
            {'id': lessons[i].id}
          );
          
          final questionsResponse = await http.get(
            Uri.parse(questionsUrl),
            headers: {
              'Content-Type': 'application/json',
              if (AppConfig.apiKey.isNotEmpty) 'Authorization': 'Bearer ${AppConfig.apiKey}',
            },
          ).timeout(_timeout);

          if (questionsResponse.statusCode == 200) {
            final List<dynamic> questionsJson = jsonDecode(questionsResponse.body);
            // You'll need to update this based on your QuizQuestion model
            // For now, keeping the existing lesson
          }
        }
      }
      
      return lessons;
    } catch (e) {
      print('Error fetching lessons with questions: $e');
      rethrow;
    }
  }
}