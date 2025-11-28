enum QuestionType {
  multipleChoice,
  fillInBlank,
  trueOrFalse,
  listening,
  speaking,
}

enum Difficulty {
  beginner,
  intermediate,
  advanced,
}

class QuizQuestion {
  final String id;
  final String question;
  final String correctAnswer;
  final List<String> options;
  final QuestionType type;
  final Difficulty difficulty;
  final String language;
  final String? audioUrl;
  final String? imageUrl;
  final String? explanation;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.correctAnswer,
    required this.options,
    this.type = QuestionType.multipleChoice,
    this.difficulty = Difficulty.beginner,
    this.language = 'Mixed',
    this.audioUrl,
    this.imageUrl,
    this.explanation,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'correctAnswer': correctAnswer,
      'options': options,
      'type': type.name,
      'difficulty': difficulty.name,
      'language': language,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'explanation': explanation,
    };
  }

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    // Handle type - may be uppercase with underscore (API) or camelCase (local)
    // API: "MULTIPLE_CHOICE" -> Flutter: "multipleChoice"
    String typeStr = (json['type'] as String?)?.toLowerCase() ?? 'multiplechoice';
    typeStr = typeStr.replaceAll('_', ''); // Remove underscores: multiple_choice -> multiplechoice
    
    // Handle difficulty - may be uppercase (API) or lowercase (local)
    final difficultyStr = (json['difficulty'] as String?)?.toLowerCase() ?? 'beginner';
    
    return QuizQuestion(
      id: json['id']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      correctAnswer: json['correctAnswer']?.toString() ?? '',
      options: _parseStringList(json['options']),
      type: QuestionType.values.firstWhere(
        (e) => e.name.toLowerCase() == typeStr,
        orElse: () => QuestionType.multipleChoice,
      ),
      difficulty: Difficulty.values.firstWhere(
        (e) => e.name.toLowerCase() == difficultyStr,
        orElse: () => Difficulty.beginner,
      ),
      language: json['language']?.toString() ?? 'Mixed',
      audioUrl: json['audioUrl']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      explanation: json['explanation']?.toString(),
    );
  }

  // Helper to parse options which may be a List<String>, a single String, or null
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

  QuizQuestion copyWith({
    String? id,
    String? question,
    String? correctAnswer,
    List<String>? options,
    QuestionType? type,
    Difficulty? difficulty,
    String? language,
    String? audioUrl,
    String? imageUrl,
    String? explanation,
  }) {
    return QuizQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      options: options ?? this.options,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      language: language ?? this.language,
      audioUrl: audioUrl ?? this.audioUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      explanation: explanation ?? this.explanation,
    );
  }
}