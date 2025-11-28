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
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_timeout);
      
      final isReachable = response.statusCode == 200;
      
      return isReachable;
    } catch (e) {
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
      
      if (language != null) {
        url = AppConfig.buildLessonsEndpoint('lessonsByLanguage', {'language': language});
      } else if (difficulty != null) {
        url = AppConfig.buildLessonsEndpoint('lessonsByDifficulty', {'difficulty': difficulty});
      } else {
        url = AppConfig.buildLessonsEndpoint('lessons');
      }

      print('🌐 [API] Fetching lessons from URL: $url');
      
      final stopwatch = Stopwatch()..start();
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (AppConfig.apiKey.isNotEmpty) 'Authorization': 'Bearer ${AppConfig.apiKey}',
        },
      ).timeout(_timeout);
      stopwatch.stop();

      print('📡 [API] Response status: ${response.statusCode} (${stopwatch.elapsedMilliseconds}ms)');

      if (response.statusCode == 200) {
        // Check if response body is empty or null
        if (response.body.isEmpty) {
          print('⚠️ [API] Response body is empty');
          return <Lesson>[];
        }
        
        print('📄 [API] Response body (first 500 chars): ${response.body.length > 500 ? response.body.substring(0, 500) : response.body}');
        
        // Parse JSON safely
        final dynamic jsonData = jsonDecode(response.body);
        
        // Check if the parsed data is actually a list
        if (jsonData == null) {
          print('⚠️ [API] Parsed JSON is null');
          return <Lesson>[];
        }
        
        if (jsonData is! List) {
          print('❌ [API] Expected List but got: ${jsonData.runtimeType}');
          throw Exception('Expected JSON array but got ${jsonData.runtimeType}');
        }
        
        final List<dynamic> jsonList = jsonData;
        print('📊 [API] Parsing ${jsonList.length} lessons...');
        
        final List<Lesson> lessons = [];
        for (int i = 0; i < jsonList.length; i++) {
          try {
            print('🔍 [API] Parsing lesson $i: ${jsonList[i]}');
            final lesson = Lesson.fromJson(jsonList[i]);
            lessons.add(lesson);
            print('✅ [API] Lesson $i parsed: ${lesson.title}');
          } catch (e) {
            print('❌ [API] Error parsing lesson $i: $e');
            print('📄 [API] Raw JSON for lesson $i: ${jsonList[i]}');
          }
        }
        
        print('✅ [API] Successfully parsed ${lessons.length}/${jsonList.length} lessons');
        return lessons;
      } else {
        print('❌ [API] Request failed: ${response.statusCode} ${response.reasonPhrase}');
        throw Exception('Failed to fetch lessons: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('💥 [API] Exception: $e');
      rethrow;
    }
  }

  /// Fetch a specific lesson by ID
  static Future<Lesson?> fetchLessonById(String lessonId) async {
    try {
      final url = AppConfig.buildLessonsEndpoint('lessonById', {'id': lessonId});

      
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
        return lesson;
      } else if (response.statusCode == 404) {
        return null; // Lesson not found
      } else {
        throw Exception('Failed to fetch lesson: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
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
            // TODO: Parse questions and add to lesson when QuizQuestion model is ready
            // final List<dynamic> questionsJson = jsonDecode(questionsResponse.body);
          }
        }
      }
      
      return lessons;
    } catch (e) {
      rethrow;
    }
  }
}