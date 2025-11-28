import 'package:flutter/material.dart';

enum GoalType { daily, weekly, monthly }

enum GoalCategory { lessons, minutes, xp, streak, accuracy }

class Goal {
  final String id;
  final String title;
  final String description;
  final GoalType type;
  final GoalCategory category;
  final int targetValue;
  int currentValue;
  final DateTime createdAt;
  final DateTime? completedAt;
  final IconData icon;
  final Color color;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.targetValue,
    this.currentValue = 0,
    required this.createdAt,
    this.completedAt,
    IconData? icon,
    Color? color,
  })  : icon = icon ?? getDefaultIcon(category),
        color = color ?? getDefaultColor(category);

  bool get isCompleted => currentValue >= targetValue;

  double get progress => (currentValue / targetValue).clamp(0.0, 1.0);

  String get typeLabel {
    switch (type) {
      case GoalType.daily:
        return 'Daily';
      case GoalType.weekly:
        return 'Weekly';
      case GoalType.monthly:
        return 'Monthly';
    }
  }

  String get categoryLabel {
    switch (category) {
      case GoalCategory.lessons:
        return 'Lessons';
      case GoalCategory.minutes:
        return 'Minutes';
      case GoalCategory.xp:
        return 'XP';
      case GoalCategory.streak:
        return 'Streak';
      case GoalCategory.accuracy:
        return 'Accuracy %';
    }
  }

  static IconData getDefaultIcon(GoalCategory category) {
    switch (category) {
      case GoalCategory.lessons:
        return Icons.book;
      case GoalCategory.minutes:
        return Icons.timer;
      case GoalCategory.xp:
        return Icons.stars;
      case GoalCategory.streak:
        return Icons.local_fire_department;
      case GoalCategory.accuracy:
        return Icons.track_changes;
    }
  }

  static Color getDefaultColor(GoalCategory category) {
    switch (category) {
      case GoalCategory.lessons:
        return Colors.deepPurple;
      case GoalCategory.minutes:
        return Colors.blue;
      case GoalCategory.xp:
        return Colors.amber;
      case GoalCategory.streak:
        return Colors.orange;
      case GoalCategory.accuracy:
        return Colors.green;
    }
  }

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    GoalType? type,
    GoalCategory? category,
    int? targetValue,
    int? currentValue,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'category': category.name,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: GoalType.values.firstWhere((e) => e.name == json['type']),
      category: GoalCategory.values.firstWhere((e) => e.name == json['category']),
      targetValue: json['targetValue'],
      currentValue: json['currentValue'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    );
  }
}
