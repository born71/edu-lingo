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
    return Lesson(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      questions: (json['questions'] as List)
          .map((q) => QuizQuestion.fromJson(q))
          .toList(),
      language: json['language'] ?? 'Mixed',
      difficulty: Difficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => Difficulty.beginner,
      ),
      iconUrl: json['iconUrl'],
      estimatedMinutes: json['estimatedMinutes'] ?? 10,
      topics: List<String>.from(json['topics'] ?? []),
    );
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