/// Configuration for microservices architecture
class AppConfig {
  // ===== MICROSERVICES CONFIGURATION =====
  
  /// Lessons Service (Spring Boot - Port 8081)
  static const String lessonsServiceUrl = 'http://localhost:8081/api';
  
  /// Future services (to be implemented)
  static const String userProgressServiceUrl = 'http://localhost:8082/api';
  static const String authServiceUrl = 'http://localhost:8083/api';
  static const String analyticsServiceUrl = 'http://localhost:8084/api';
  
  /// Production URLs (update when deploying)
  static const String prodLessonsServiceUrl = 'https://your-domain.com/lessons/api';
  static const String prodUserProgressServiceUrl = 'https://your-domain.com/progress/api';
  static const String prodAuthServiceUrl = 'https://your-domain.com/auth/api';
  static const String prodAnalyticsServiceUrl = 'https://your-domain.com/analytics/api';
  
  /// API authentication key (if needed)
  static const String apiKey = 'your-api-key-here';
  
  /// Request timeout duration
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // ===== DATABASE TABLE NAMES =====
  /// These should match your database schema
  
  static const String usersTable = 'users';
  static const String lessonsTable = 'lessons';
  static const String questionsTable = 'questions';
  static const String userProgressTable = 'user_progress';
  static const String answersTable = 'user_answers';
  static const String achievementsTable = 'achievements';
  
  // ===== MICROSERVICE ENDPOINTS =====
  
  /// Lessons Service Endpoints
  static const Map<String, String> lessonsEndpoints = {
    'lessons': '/lessons',
    'lessonById': '/lessons/{id}',
    'lessonQuestions': '/lessons/{id}/questions', 
    'searchLessons': '/lessons/search',
    'createLesson': '/lessons',
    'updateLesson': '/lessons/{id}',
    'deleteLesson': '/lessons/{id}',
    'lessonsByLanguage': '/lessons/language/{language}',
    'lessonsByDifficulty': '/lessons/difficulty/{difficulty}',
    'health': '/actuator/health',
  };
  
  /// User Progress Service Endpoints (Future)
  static const Map<String, String> progressEndpoints = {
    'userProgress': '/users/{userId}/progress',
    'lessonProgress': '/users/{userId}/lessons/{lessonId}/progress',
    'recordAnswer': '/users/{userId}/answers',
    'syncProgress': '/users/{userId}/sync',
    'streaks': '/users/{userId}/streaks',
    'achievements': '/users/{userId}/achievements',
  };
  
  /// Auth Service Endpoints (Future)
  static const Map<String, String> authEndpoints = {
    'login': '/auth/login',
    'register': '/auth/register',
    'logout': '/auth/logout',
    'refresh': '/auth/refresh',
    'profile': '/auth/profile',
    'changePassword': '/auth/change-password',
  };
  
  /// Analytics Service Endpoints (Future) 
  static const Map<String, String> analyticsEndpoints = {
    'userStats': '/users/{userId}/stats',
    'leaderboard': '/leaderboard',
    'systemStats': '/stats/system',
    'lessonStats': '/stats/lessons',
    'globalProgress': '/stats/global',
  };
  
  // ===== APP SETTINGS =====
  
  /// Enable offline mode
  static const bool enableOfflineMode = true;
  
  /// Enable data compression for API requests
  static const bool enableCompression = true;
  
  /// Enable detailed logging
  static const bool enableLogging = true;
  
  /// Cache duration for lessons (in hours)
  static const int lessonCacheHours = 24;
  
  /// Auto-sync interval (in minutes)
  static const int autoSyncIntervalMinutes = 15;
  
  // ===== DEVELOPMENT SETTINGS =====
  
  /// Use mock data when server is unavailable
  static const bool useMockDataInDev = true;
  
  /// Enable debug mode
  static const bool isDebugMode = true; // Set to false for production
  
  // ===== HELPER METHODS =====
  
  /// Get lessons service URL based on environment
  static String get effectiveLessonsServiceUrl {
    return isDebugMode ? lessonsServiceUrl : prodLessonsServiceUrl;
  }
  
  /// Get user progress service URL based on environment
  static String get effectiveProgressServiceUrl {
    return isDebugMode ? userProgressServiceUrl : prodUserProgressServiceUrl;
  }
  
  /// Get auth service URL based on environment
  static String get effectiveAuthServiceUrl {
    return isDebugMode ? authServiceUrl : prodAuthServiceUrl;
  }
  
  /// Get analytics service URL based on environment
  static String get effectiveAnalyticsServiceUrl {
    return isDebugMode ? analyticsServiceUrl : prodAnalyticsServiceUrl;
  }
  
  /// Build lessons service endpoint URL
  static String buildLessonsEndpoint(String key, [Map<String, String>? params]) {
    String endpoint = lessonsEndpoints[key] ?? '';
    
    if (params != null) {
      params.forEach((key, value) {
        endpoint = endpoint.replaceAll('{$key}', value);
      });
    }
    
    return effectiveLessonsServiceUrl + endpoint;
  }
  
  /// Build progress service endpoint URL
  static String buildProgressEndpoint(String key, [Map<String, String>? params]) {
    String endpoint = progressEndpoints[key] ?? '';
    
    if (params != null) {
      params.forEach((key, value) {
        endpoint = endpoint.replaceAll('{$key}', value);
      });
    }
    
    return effectiveProgressServiceUrl + endpoint;
  }
  
  /// Build auth service endpoint URL
  static String buildAuthEndpoint(String key, [Map<String, String>? params]) {
    String endpoint = authEndpoints[key] ?? '';
    
    if (params != null) {
      params.forEach((key, value) {
        endpoint = endpoint.replaceAll('{$key}', value);
      });
    }
    
    return effectiveAuthServiceUrl + endpoint;
  }
  
  /// Build analytics service endpoint URL
  static String buildAnalyticsEndpoint(String key, [Map<String, String>? params]) {
    String endpoint = analyticsEndpoints[key] ?? '';
    
    if (params != null) {
      params.forEach((key, value) {
        endpoint = endpoint.replaceAll('{$key}', value);
      });
    }
    
    return effectiveAnalyticsServiceUrl + endpoint;
  }
}

// ===== EXAMPLE DATABASE SCHEMA =====
/* 

Here's an example SQL schema for your database:

-- Users table
CREATE TABLE users (
  id VARCHAR(255) PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  display_name VARCHAR(255),
  preferred_language VARCHAR(50) DEFAULT 'Spanish',
  daily_goal_minutes INT DEFAULT 15,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Lessons table
CREATE TABLE lessons (
  id VARCHAR(255) PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  language VARCHAR(50) NOT NULL,
  difficulty ENUM('beginner', 'intermediate', 'advanced') DEFAULT 'beginner',
  estimated_minutes INT DEFAULT 10,
  topics JSON,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Questions table
CREATE TABLE questions (
  id VARCHAR(255) PRIMARY KEY,
  lesson_id VARCHAR(255) NOT NULL,
  question TEXT NOT NULL,
  correct_answer VARCHAR(255) NOT NULL,
  options JSON NOT NULL,
  type ENUM('multipleChoice', 'fillInBlank', 'trueOrFalse', 'listening', 'speaking') DEFAULT 'multipleChoice',
  difficulty ENUM('beginner', 'intermediate', 'advanced') DEFAULT 'beginner',
  language VARCHAR(50),
  audio_url VARCHAR(500),
  image_url VARCHAR(500),
  explanation TEXT,
  order_index INT DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE,
  INDEX idx_lesson_order (lesson_id, order_index)
);

-- User progress table
CREATE TABLE user_progress (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id VARCHAR(255) NOT NULL,
  lesson_id VARCHAR(255) NOT NULL,
  questions_completed INT DEFAULT 0,
  total_questions INT DEFAULT 0,
  correct_answers INT DEFAULT 0,
  is_completed BOOLEAN DEFAULT false,
  attempt_count INT DEFAULT 0,
  last_completed_at TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE,
  UNIQUE KEY unique_user_lesson (user_id, lesson_id)
);

-- User answers table (for detailed tracking)
CREATE TABLE user_answers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id VARCHAR(255) NOT NULL,
  lesson_id VARCHAR(255) NOT NULL,
  question_id VARCHAR(255) NOT NULL,
  selected_answer VARCHAR(255) NOT NULL,
  is_correct BOOLEAN NOT NULL,
  response_time_ms INT DEFAULT 0,
  answered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE,
  FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
  INDEX idx_user_lesson (user_id, lesson_id),
  INDEX idx_answered_at (answered_at)
);

-- User statistics table (for quick access to computed stats)
CREATE TABLE user_stats (
  user_id VARCHAR(255) PRIMARY KEY,
  total_xp INT DEFAULT 0,
  current_streak INT DEFAULT 0,
  last_study_date DATE NULL,
  total_lessons_completed INT DEFAULT 0,
  total_questions_answered INT DEFAULT 0,
  total_correct_answers INT DEFAULT 0,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

*/