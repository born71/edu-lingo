/// Configuration for your database/API server
class AppConfig {
  // ===== API CONFIGURATION =====
  
  /// Your server base URL
  /// Replace this with your actual server URL
  static const String apiBaseUrl = 'https://your-server.com/api';
  
  /// API authentication key (if needed)
  /// You might get this from your server admin panel
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
  
  // ===== API ENDPOINTS =====
  /// Define your API endpoints here
  
  static const Map<String, String> endpoints = {
    // Authentication
    'login': '/auth/login',
    'register': '/auth/register',
    'logout': '/auth/logout',
    
    // Lessons
    'lessons': '/lessons',
    'lessonById': '/lessons/{id}',
    'lessonQuestions': '/lessons/{id}/questions',
    'searchLessons': '/lessons/search',
    
    // User Progress
    'userProgress': '/users/{userId}/progress',
    'syncProgress': '/users/{userId}/sync',
    'recordAnswer': '/users/{userId}/answers',
    
    // Analytics
    'userStats': '/users/{userId}/stats',
    'leaderboard': '/leaderboard',
    'achievements': '/users/{userId}/achievements',
    
    // Content
    'languages': '/languages',
    'topics': '/topics',
    'difficulties': '/difficulties',
    
    // System
    'health': '/health',
    'version': '/version',
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
  
  /// Development server URL (for testing)
  static const String devApiBaseUrl = 'http://localhost:3000/api';
  
  /// Enable debug mode
  static const bool isDebugMode = true; // Set to false for production
  
  // ===== HELPER METHODS =====
  
  /// Get the appropriate base URL based on environment
  static String get effectiveApiUrl {
    return isDebugMode ? devApiBaseUrl : apiBaseUrl;
  }
  
  /// Build full endpoint URL
  static String buildEndpoint(String key, [Map<String, String>? params]) {
    String endpoint = endpoints[key] ?? '';
    
    if (params != null) {
      params.forEach((key, value) {
        endpoint = endpoint.replaceAll('{$key}', value);
      });
    }
    
    return effectiveApiUrl + endpoint;
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