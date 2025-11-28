import 'quiz_question.dart';

class Lesson {
  final String id;
  final String title;
  final String description;
  final List<QuizQuestion> questions;
  final String language;
  final Difficulty difficulty;
  final String? iconUrl;
  final int estimatedMinutes;
  final List<String> topics;

  const Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    this.language = 'Mixed',
    this.difficulty = Difficulty.beginner,
    this.iconUrl,
    this.estimatedMinutes = 10,
    this.topics = const [],
  });

  int get totalQuestions => questions.length;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toJson()).toList(),
      'language': language,
      'difficulty': difficulty.name,
      'iconUrl': iconUrl,
      'estimatedMinutes': estimatedMinutes,
      'topics': topics,
    };
  }

  factory Lesson.fromJson(Map<String, dynamic> json) {
    // Handle questions - may be null, empty, or a list
    List<QuizQuestion> parsedQuestions = [];
    if (json['questions'] != null && json['questions'] is List) {
      parsedQuestions = (json['questions'] as List)
          .map((q) => QuizQuestion.fromJson(q))
          .toList();
    }
    
    // Handle difficulty - may be uppercase (API) or lowercase (local)
    final difficultyStr = (json['difficulty'] as String?)?.toLowerCase() ?? 'beginner';
    
    return Lesson(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      questions: parsedQuestions,
      language: json['language']?.toString() ?? 'Mixed',
      difficulty: Difficulty.values.firstWhere(
        (e) => e.name.toLowerCase() == difficultyStr,
        orElse: () => Difficulty.beginner,
      ),
      iconUrl: json['iconUrl']?.toString(),
      estimatedMinutes: json['estimatedMinutes'] as int? ?? 10,
      topics: _parseStringList(json['topics']),
    );
  }

  // Helper to parse topics which may be a List<String>, a single String, or null
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String) {
      // If it's a comma-separated string, split it
      if (value.contains(',')) {
        return value.split(',').map((e) => e.trim()).toList();
      }
      return [value];
    }
    return [];
  }

  Lesson copyWith({
    String? id,
    String? title,
    String? description,
    List<QuizQuestion>? questions,
    String? language,
    Difficulty? difficulty,
    String? iconUrl,
    int? estimatedMinutes,
    List<String>? topics,
  }) {
    return Lesson(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      questions: questions ?? this.questions,
      language: language ?? this.language,
      difficulty: difficulty ?? this.difficulty,
      iconUrl: iconUrl ?? this.iconUrl,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      topics: topics ?? this.topics,
    );
  }
}