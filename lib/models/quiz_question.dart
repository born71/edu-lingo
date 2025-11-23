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
    return QuizQuestion(
      id: json['id'],
      question: json['question'],
      correctAnswer: json['correctAnswer'],
      options: List<String>.from(json['options']),
      type: QuestionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => QuestionType.multipleChoice,
      ),
      difficulty: Difficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => Difficulty.beginner,
      ),
      language: json['language'] ?? 'Mixed',
      audioUrl: json['audioUrl'],
      imageUrl: json['imageUrl'],
      explanation: json['explanation'],
    );
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