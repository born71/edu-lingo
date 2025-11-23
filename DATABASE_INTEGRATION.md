# Database Server Integration Guide

## 🗄️ **Database Server Setup**

Yes, you can absolutely replace the static `lesson_data.dart` with your database server! I've prepared the complete architecture for you.

### ✅ **What's Already Implemented:**

1. **ApiService** - Complete REST API client
2. **HybridStorageService** - Seamless online/offline data management
3. **AppConfig** - Centralized configuration
4. **Updated ProgressProvider** - Now uses API + local cache

### 🚀 **How to Connect Your Database:**

#### **Step 1: Configure Your Server URL**

Edit `lib/config/app_config.dart`:

```dart
// Replace with your actual server URL
static const String apiBaseUrl = 'https://your-server.com/api';

// Add your API key if needed
static const String apiKey = 'your-api-key-here';
```

#### **Step 2: Database Schema**

Use the provided SQL schema in `app_config.dart` or adapt it to your database:

- **users** - User accounts and preferences
- **lessons** - Lesson content and metadata
- **questions** - Quiz questions and answers
- **user_progress** - Learning progress tracking
- **user_answers** - Detailed answer history
- **user_stats** - Computed statistics

#### **Step 3: API Endpoints**

Your server should implement these endpoints:

**Lessons:**
- `GET /lessons` - Fetch all lessons
- `GET /lessons/{id}` - Get specific lesson
- `GET /lessons/{id}/questions` - Get lesson questions
- `GET /lessons/search?q=...` - Search lessons

**User Progress:**
- `GET /users/{userId}/progress` - Get user progress
- `POST /users/{userId}/progress` - Save user progress
- `POST /users/{userId}/answers` - Record individual answers

**Authentication:**
- `POST /auth/login` - User login
- `POST /auth/register` - User registration

**Analytics:**
- `GET /users/{userId}/analytics` - User statistics
- `GET /leaderboard` - Top learners

#### **Step 4: Test Connection**

Your API should respond to `GET /health` for connectivity testing.

### 🔄 **How the Hybrid System Works:**

1. **Online**: Fetches fresh data from your server
2. **Offline**: Uses cached data from local storage
3. **Sync**: Automatically syncs when connection is restored
4. **Fallback**: Uses built-in lessons if both fail

### 💡 **Server Technology Suggestions:**

**Backend Options:**
- **Node.js + Express** (JavaScript)
- **Laravel** (PHP)
- **Django/FastAPI** (Python)
- **Spring Boot** (Java)
- **ASP.NET Core** (C#)

**Database Options:**
- **MySQL** (Recommended for structured data)
- **PostgreSQL** (Advanced features)
- **Firebase** (Google's BaaS)
- **Supabase** (Open-source Firebase alternative)
- **MongoDB** (NoSQL option)

### 🛠️ **Quick Start with Firebase:**

If you want a quick setup, Firebase is easiest:

1. Create Firebase project
2. Enable Firestore Database
3. Set up Authentication
4. Update `ApiService` to use Firebase SDK

### 📊 **Sample API Responses:**

**GET /lessons:**
```json
[
  {
    "id": "spanish_basics",
    "title": "Spanish Basics",
    "description": "Learn fundamental Spanish vocabulary",
    "language": "Spanish",
    "difficulty": "beginner",
    "estimatedMinutes": 15,
    "topics": ["greetings", "numbers"],
    "questions": [...]
  }
]
```

**GET /users/{userId}/progress:**
```json
{
  "totalXP": 250,
  "currentStreak": 7,
  "totalLessonsCompleted": 3,
  "totalQuestionsAnswered": 45,
  "totalCorrectAnswers": 38,
  "lessonProgress": {
    "spanish_basics": {
      "lessonId": "spanish_basics",
      "questionsCompleted": 15,
      "correctAnswers": 13,
      "isCompleted": true
    }
  }
}
```

### 🔧 **Implementation Priority:**

1. **Start Simple**: Implement basic lesson fetching
2. **Add Progress**: User progress tracking
3. **Add Auth**: User authentication
4. **Add Analytics**: Statistics and leaderboards
5. **Add Features**: Search, recommendations, etc.

### 🚨 **Important Notes:**

- The app works offline-first (graceful degradation)
- All data is cached locally for performance
- Progress syncs automatically when online
- Fallback to static lessons if server fails

Your app is now ready for database integration! Just update the configuration and implement your server endpoints.

## 📝 **Next Steps:**

1. Set up your database server
2. Update `app_config.dart` with your server URL
3. Test with `flutter run`
4. The app will seamlessly switch between server and local data

Would you like help with any specific backend technology or database setup?