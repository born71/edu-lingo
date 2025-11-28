import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/goal.dart';

class GoalProvider extends ChangeNotifier {
  List<Goal> _goals = [];
  bool _isLoading = false;

  List<Goal> get goals => _goals;
  bool get isLoading => _isLoading;

  List<Goal> get dailyGoals => _goals.where((g) => g.type == GoalType.daily).toList();
  List<Goal> get weeklyGoals => _goals.where((g) => g.type == GoalType.weekly).toList();
  List<Goal> get monthlyGoals => _goals.where((g) => g.type == GoalType.monthly).toList();

  List<Goal> get activeGoals => _goals.where((g) => !g.isCompleted).toList();
  List<Goal> get completedGoals => _goals.where((g) => g.isCompleted).toList();

  int get totalGoals => _goals.length;
  int get completedCount => completedGoals.length;
  double get overallProgress => totalGoals > 0 ? completedCount / totalGoals : 0.0;

  GoalProvider() {
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final goalsJson = prefs.getString('user_goals');
      
      if (goalsJson != null) {
        final List<dynamic> decoded = jsonDecode(goalsJson);
        _goals = decoded.map((g) => Goal.fromJson(g)).toList();
        
        // Clean up old goals based on their type
        _cleanupExpiredGoals();
      } else {
        // Add some default goals for new users
        _goals = _getDefaultGoals();
        await _saveGoals();
      }
    } catch (e) {
      _goals = _getDefaultGoals();
    }

    _isLoading = false;
    notifyListeners();
  }

  List<Goal> _getDefaultGoals() {
    final now = DateTime.now();
    return [
      Goal(
        id: 'default_daily_1',
        title: 'Complete 1 Lesson',
        description: 'Finish at least one lesson today',
        type: GoalType.daily,
        category: GoalCategory.lessons,
        targetValue: 1,
        createdAt: now,
      ),
      Goal(
        id: 'default_daily_2',
        title: 'Earn 50 XP',
        description: 'Collect 50 experience points',
        type: GoalType.daily,
        category: GoalCategory.xp,
        targetValue: 50,
        createdAt: now,
      ),
      Goal(
        id: 'default_weekly_1',
        title: 'Complete 5 Lessons',
        description: 'Finish 5 lessons this week',
        type: GoalType.weekly,
        category: GoalCategory.lessons,
        targetValue: 5,
        createdAt: now,
      ),
      Goal(
        id: 'default_monthly_1',
        title: 'Earn 1000 XP',
        description: 'Collect 1000 XP this month',
        type: GoalType.monthly,
        category: GoalCategory.xp,
        targetValue: 1000,
        createdAt: now,
      ),
    ];
  }

  void _cleanupExpiredGoals() {
    final now = DateTime.now();
    
    _goals = _goals.where((goal) {
      switch (goal.type) {
        case GoalType.daily:
          // Keep if created today
          return goal.createdAt.day == now.day &&
                 goal.createdAt.month == now.month &&
                 goal.createdAt.year == now.year;
        case GoalType.weekly:
          // Keep if created within last 7 days
          return now.difference(goal.createdAt).inDays < 7;
        case GoalType.monthly:
          // Keep if created within same month
          return goal.createdAt.month == now.month &&
                 goal.createdAt.year == now.year;
      }
    }).toList();
  }

  Future<void> _saveGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final goalsJson = jsonEncode(_goals.map((g) => g.toJson()).toList());
      await prefs.setString('user_goals', goalsJson);
    } catch (e) {
    }
  }

  Future<void> addGoal(Goal goal) async {
    _goals.add(goal);
    await _saveGoals();
    notifyListeners();
  }

  Future<void> updateGoal(Goal updatedGoal) async {
    final index = _goals.indexWhere((g) => g.id == updatedGoal.id);
    if (index != -1) {
      _goals[index] = updatedGoal;
      await _saveGoals();
      notifyListeners();
    }
  }

  Future<void> deleteGoal(String goalId) async {
    _goals.removeWhere((g) => g.id == goalId);
    await _saveGoals();
    notifyListeners();
  }

  Future<void> updateGoalProgress(String goalId, int newValue) async {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      _goals[index] = _goals[index].copyWith(
        currentValue: newValue,
        completedAt: newValue >= _goals[index].targetValue ? DateTime.now() : null,
      );
      await _saveGoals();
      notifyListeners();
    }
  }

  Future<void> incrementGoalProgress(GoalCategory category, int amount) async {
    for (int i = 0; i < _goals.length; i++) {
      if (_goals[i].category == category && !_goals[i].isCompleted) {
        final newValue = _goals[i].currentValue + amount;
        _goals[i] = _goals[i].copyWith(
          currentValue: newValue,
          completedAt: newValue >= _goals[i].targetValue ? DateTime.now() : null,
        );
      }
    }
    await _saveGoals();
    notifyListeners();
  }

  Future<void> resetDailyGoals() async {
    final now = DateTime.now();
    _goals = _goals.map((goal) {
      if (goal.type == GoalType.daily) {
        return goal.copyWith(
          currentValue: 0,
          completedAt: null,
          createdAt: now,
        );
      }
      return goal;
    }).toList();
    await _saveGoals();
    notifyListeners();
  }

  Future<void> refresh() async {
    await _loadGoals();
  }
}
