import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lesson.dart';
import '../models/quiz_question.dart';
import '../models/user_progress.dart';
import '../config/app_config.dart';

class ApiService {
  // Use configuration from AppConfig
  static String get baseUrl => AppConfig.effectiveApiUrl;
  static String get apiKey => AppConfig.apiKey;
  
  // HTTP client for making requests
  static final http.Client _client = http.Client();
  
  // Common headers for API requests
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey',
  };

  // ===== LESSON ENDPOINTS =====
  
  /// Fetch all available lessons from server
  static Future<List<Lesson>> fetchLessons({String? language, String? difficulty}) async {
    try {
      final queryParams = <String, String>{};
      if (language != null) queryParams['language'] = language;
      if (difficulty != null) queryParams['difficulty'] = difficulty;
      
      final uri = Uri.parse('$baseUrl/lessons').replace(queryParameters: queryParams);
      final response = await _client.get(uri, headers: _headers);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Lesson.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to fetch lessons: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Network error fetching lessons: $e');
    }
  }
  
  /// Fetch a specific lesson by ID
  static Future<Lesson> fetchLesson(String lessonId) async {
    try {
      final uri = Uri.parse('$baseUrl/lessons/$lessonId');
      final response = await _client.get(uri, headers: _headers);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Lesson.fromJson(data);
      } else {
        throw ApiException('Failed to fetch lesson: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Network error fetching lesson: $e');
    }
  }
  
  /// Fetch questions for a specific lesson
  static Future<List<QuizQuestion>> fetchLessonQuestions(String lessonId) async {
    try {
      final uri = Uri.parse('$baseUrl/lessons/$lessonId/questions');
      final response = await _client.get(uri, headers: _headers);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => QuizQuestion.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to fetch questions: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Network error fetching questions: $e');
    }
  }

  // ===== USER PROGRESS ENDPOINTS =====
  
  /// Sync user progress to server
  static Future<bool> syncUserProgress(String userId, UserProgress progress) async {
    try {
      final uri = Uri.parse('$baseUrl/users/$userId/progress');
      final response = await _client.post(
        uri,
        headers: _headers,
        body: jsonEncode(progress.toJson()),
      );
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error syncing progress: $e');
      return false;
    }
  }
  
  /// Fetch user progress from server
  static Future<UserProgress?> fetchUserProgress(String userId) async {
    try {
      final uri = Uri.parse('$baseUrl/users/$userId/progress');
      final response = await _client.get(uri, headers: _headers);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return UserProgress.fromJson(data);
      } else if (response.statusCode == 404) {
        // User progress not found, return null for new user
        return null;
      } else {
        throw ApiException('Failed to fetch user progress: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Network error fetching progress: $e');
    }
  }
  
  /// Record a single answer to the server
  static Future<bool> recordAnswer({
    required String userId,
    required String lessonId,
    required String questionId,
    required String selectedAnswer,
    required bool isCorrect,
    required DateTime timestamp,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/users/$userId/answers');
      final response = await _client.post(
        uri,
        headers: _headers,
        body: jsonEncode({
          'lessonId': lessonId,
          'questionId': questionId,
          'selectedAnswer': selectedAnswer,
          'isCorrect': isCorrect,
          'timestamp': timestamp.toIso8601String(),
        }),
      );
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error recording answer: $e');
      return false;
    }
  }

  // ===== ANALYTICS ENDPOINTS =====
  
  /// Fetch user analytics/statistics
  static Future<Map<String, dynamic>> fetchUserAnalytics(String userId) async {
    try {
      final uri = Uri.parse('$baseUrl/users/$userId/analytics');
      final response = await _client.get(uri, headers: _headers);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw ApiException('Failed to fetch analytics: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Network error fetching analytics: $e');
    }
  }
  
  /// Fetch leaderboard data
  static Future<List<Map<String, dynamic>>> fetchLeaderboard({int limit = 10}) async {
    try {
      final uri = Uri.parse('$baseUrl/leaderboard?limit=$limit');
      final response = await _client.get(uri, headers: _headers);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw ApiException('Failed to fetch leaderboard: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Network error fetching leaderboard: $e');
    }
  }

  // ===== USER MANAGEMENT =====
  
  /// Create or login user
  static Future<String> authenticateUser({
    required String email,
    String? password,
    String? displayName,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/login');
      final response = await _client.post(
        uri,
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
          'displayName': displayName,
        }),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['userId'] ?? data['user_id'];
      } else {
        throw ApiException('Authentication failed: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Network error during authentication: $e');
    }
  }

  // ===== CONTENT MANAGEMENT =====
  
  /// Fetch available languages
  static Future<List<String>> fetchAvailableLanguages() async {
    try {
      final uri = Uri.parse('$baseUrl/languages');
      final response = await _client.get(uri, headers: _headers);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<String>();
      } else {
        throw ApiException('Failed to fetch languages: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Network error fetching languages: $e');
    }
  }
  
  /// Search lessons by topic or keyword
  static Future<List<Lesson>> searchLessons(String query) async {
    try {
      final uri = Uri.parse('$baseUrl/lessons/search?q=${Uri.encodeComponent(query)}');
      final response = await _client.get(uri, headers: _headers);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Lesson.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to search lessons: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Network error searching lessons: $e');
    }
  }

  // ===== OFFLINE SUPPORT =====
  
  /// Check server connectivity
  static Future<bool> isServerReachable() async {
    try {
      final uri = Uri.parse('$baseUrl/health');
      final response = await _client.get(uri, headers: _headers).timeout(
        const Duration(seconds: 5),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  /// Batch sync for offline data
  static Future<bool> batchSync(Map<String, dynamic> offlineData) async {
    try {
      final uri = Uri.parse('$baseUrl/sync');
      final response = await _client.post(
        uri,
        headers: _headers,
        body: jsonEncode(offlineData),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error in batch sync: $e');
      return false;
    }
  }

  // ===== CLEANUP =====
  
  static void dispose() {
    _client.close();
  }
}

// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  
  ApiException(this.message);
  
  @override
  String toString() => 'ApiException: $message';
}

// Configuration class for API settings
class ApiConfig {
  static String baseUrl = 'https://your-api-server.com/api';
  static String apiKey = 'your-api-key';
  static Duration timeout = const Duration(seconds: 30);
  static bool enableLogging = true;
  
  static void configure({
    required String serverUrl,
    String? key,
    Duration? requestTimeout,
    bool? logging,
  }) {
    baseUrl = serverUrl;
    if (key != null) apiKey = key;
    if (requestTimeout != null) timeout = requestTimeout;
    if (logging != null) enableLogging = logging;
  }
}