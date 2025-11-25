class LessonProgress {
  final String lessonId;
  final int questionsCompleted;
  final int totalQuestions;
  final int correctAnswers;
  final DateTime? lastCompletedAt;
  final bool isCompleted;
  final List<String> incorrectAnswerIds;
  final int attemptCount;

  const LessonProgress({
    required this.lessonId,
    this.questionsCompleted = 0,
    this.totalQuestions = 0,
    this.correctAnswers = 0,
    this.lastCompletedAt,
    this.isCompleted = false,
    this.incorrectAnswerIds = const [],
    this.attemptCount = 0,
  });

  double get progressPercentage => 
      totalQuestions > 0 ? questionsCompleted / totalQuestions : 0.0;

  double get accuracyPercentage => 
      questionsCompleted > 0 ? correctAnswers / questionsCompleted : 0.0;

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'questionsCompleted': questionsCompleted,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'lastCompletedAt': lastCompletedAt?.toIso8601String(),
      'isCompleted': isCompleted,
      'incorrectAnswerIds': incorrectAnswerIds,
      'attemptCount': attemptCount,
    };
  }

  factory LessonProgress.fromJson(Map<String, dynamic> json) {
    return LessonProgress(
      lessonId: json['lessonId'],
      questionsCompleted: json['questionsCompleted'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
      correctAnswers: json['correctAnswers'] ?? 0,
      lastCompletedAt: json['lastCompletedAt'] != null 
          ? DateTime.parse(json['lastCompletedAt'])
          : null,
      isCompleted: json['isCompleted'] ?? false,
      incorrectAnswerIds: List<String>.from(json['incorrectAnswerIds'] ?? []),
      attemptCount: json['attemptCount'] ?? 0,
    );
  }

  LessonProgress copyWith({
    String? lessonId,
    int? questionsCompleted,
    int? totalQuestions,
    int? correctAnswers,
    DateTime? lastCompletedAt,
    bool? isCompleted,
    List<String>? incorrectAnswerIds,
    int? attemptCount,
  }) {
    return LessonProgress(
      lessonId: lessonId ?? this.lessonId,
      questionsCompleted: questionsCompleted ?? this.questionsCompleted,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      incorrectAnswerIds: incorrectAnswerIds ?? this.incorrectAnswerIds,
      attemptCount: attemptCount ?? this.attemptCount,
    );
  }
}

class UserProgress {
  final Map<String, LessonProgress> lessonProgress;
  final int totalXP;
  final int currentStreak;
  final DateTime? lastStudyDate;
  final int totalLessonsCompleted;
  final int totalQuestionsAnswered;
  final int totalCorrectAnswers;
  final DateTime createdAt;
  final String preferredLanguage;
  final int dailyGoal; // in minutes
  
  // Profile fields
  final String displayName;
  final String email;
  final String bio;
  final String avatarUrl;

  UserProgress({
    this.lessonProgress = const {},
    this.totalXP = 0,
    this.currentStreak = 0,
    this.lastStudyDate,
    this.totalLessonsCompleted = 0,
    this.totalQuestionsAnswered = 0,
    this.totalCorrectAnswers = 0,
    DateTime? createdAt,
    this.preferredLanguage = 'Spanish',
    this.dailyGoal = 15,
    this.displayName = '',
    this.email = '',
    this.bio = '',
    this.avatarUrl = '',
  }) : createdAt = createdAt ?? DateTime.now();

  double get overallAccuracy => totalQuestionsAnswered > 0 
      ? totalCorrectAnswers / totalQuestionsAnswered 
      : 0.0;

  bool get hasStudiedToday {
    if (lastStudyDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastStudy = DateTime(
      lastStudyDate!.year, 
      lastStudyDate!.month, 
      lastStudyDate!.day
    );
    return today == lastStudy;
  }

  int get daysStudying {
    final now = DateTime.now();
    final daysDiff = now.difference(createdAt).inDays;
    return daysDiff + 1;
  }

  LessonProgress? getLessonProgress(String lessonId) {
    return lessonProgress[lessonId];
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonProgress': lessonProgress.map(
        (key, value) => MapEntry(key, value.toJson())
      ),
      'totalXP': totalXP,
      'currentStreak': currentStreak,
      'lastStudyDate': lastStudyDate?.toIso8601String(),
      'totalLessonsCompleted': totalLessonsCompleted,
      'totalQuestionsAnswered': totalQuestionsAnswered,
      'totalCorrectAnswers': totalCorrectAnswers,
      'createdAt': createdAt.toIso8601String(),
      'preferredLanguage': preferredLanguage,
      'dailyGoal': dailyGoal,
      'displayName': displayName,
      'email': email,
      'bio': bio,
      'avatarUrl': avatarUrl,
    };
  }

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      lessonProgress: (json['lessonProgress'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, LessonProgress.fromJson(value))
      ) ?? {},
      totalXP: json['totalXP'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      lastStudyDate: json['lastStudyDate'] != null 
          ? DateTime.parse(json['lastStudyDate'])
          : null,
      totalLessonsCompleted: json['totalLessonsCompleted'] ?? 0,
      totalQuestionsAnswered: json['totalQuestionsAnswered'] ?? 0,
      totalCorrectAnswers: json['totalCorrectAnswers'] ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      preferredLanguage: json['preferredLanguage'] ?? 'Spanish',
      dailyGoal: json['dailyGoal'] ?? 15,
      displayName: json['displayName'] ?? '',
      email: json['email'] ?? '',
      bio: json['bio'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
    );
  }

  UserProgress copyWith({
    Map<String, LessonProgress>? lessonProgress,
    int? totalXP,
    int? currentStreak,
    DateTime? lastStudyDate,
    int? totalLessonsCompleted,
    int? totalQuestionsAnswered,
    int? totalCorrectAnswers,
    DateTime? createdAt,
    String? preferredLanguage,
    int? dailyGoal,
    String? displayName,
    String? email,
    String? bio,
    String? avatarUrl,
  }) {
    return UserProgress(
      lessonProgress: lessonProgress ?? this.lessonProgress,
      totalXP: totalXP ?? this.totalXP,
      currentStreak: currentStreak ?? this.currentStreak,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      totalLessonsCompleted: totalLessonsCompleted ?? this.totalLessonsCompleted,
      totalQuestionsAnswered: totalQuestionsAnswered ?? this.totalQuestionsAnswered,
      totalCorrectAnswers: totalCorrectAnswers ?? this.totalCorrectAnswers,
      createdAt: createdAt ?? this.createdAt,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}