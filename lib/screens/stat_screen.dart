import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/progress_provider.dart';
import '../models/user_progress.dart';
import '../widgets/base_scaffold.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Your Learning Stats',
      currentRoute: '/stats',
      body: const StatsScreenContent(),
    );
  }
}

class StatsScreenContent extends StatelessWidget {
  const StatsScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressProvider>(
        builder: (context, progressProvider, child) {
          final userProgress = progressProvider.userProgress;
          
          if (progressProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Header
                const Icon(
                  Icons.analytics,
                  size: 80,
                  color: Colors.blueGrey,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Progress Overview',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                // Overall Stats Cards
                _buildStatsGrid(userProgress, progressProvider),
                const SizedBox(height: 30),

                // Detailed Progress Section
                _buildDetailedProgress(userProgress, progressProvider),
                const SizedBox(height: 30),

                // Achievement Section
                _buildAchievements(userProgress),
                const SizedBox(height: 30),

                // Study History
                _buildStudyHistory(userProgress),
              ],
            ),
          );
        },
      );
  }

  Widget _buildStatsGrid(UserProgress userProgress, ProgressProvider progressProvider) {
  return Column(
    children: [
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        children: [
          _buildStatCard(
            'Lessons Completed',
            '${userProgress.totalLessonsCompleted}',
            Icons.check_circle,
            Colors.green,
          ),
          _buildStatCard(
            'Current Streak',
            '${userProgress.currentStreak} ${userProgress.currentStreak == 1 ? 'Day' : 'Days'}',
            Icons.local_fire_department,
            Colors.orange,
          ),
          _buildStatCard(
            'Total XP',
            '${userProgress.totalXP}',
            Icons.stars,
            Colors.amber,
          ),
          _buildStatCard(
            'Overall Accuracy',
            '${(userProgress.overallAccuracy * 100).toInt()}%',
            Icons.track_changes,
            Colors.blue,
          ),
        ],
      ),

      // const SizedBox(height: 1),

      SizedBox(
        width: double.infinity,
        child: _buildStatCard(
          'Rank',
          '-',
          Icons.smart_toy_sharp,
          Colors.pink,
        ),
      ),
    ],
  );
}


  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32), //title
            const SizedBox(height: 8),
            Text(
              value, //value
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title, //title
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600, //color
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedProgress(UserProgress userProgress, ProgressProvider progressProvider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.deepPurple.shade300),
                const SizedBox(width: 10),
                const Text(
                  'Learning Progress',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Total questions answered
            _buildProgressRow(
              'Questions Answered',
              '${userProgress.totalQuestionsAnswered}',
              Icons.quiz,
            ),
            
            // Correct answers
            _buildProgressRow(
              'Correct Answers',
              '${userProgress.totalCorrectAnswers}',
              Icons.check,
            ),
            
            // Days studying
            _buildProgressRow(
              'Days Learning',
              '${userProgress.daysStudying}',
              Icons.calendar_today,
            ),
            
            // Preferred language
            _buildProgressRow(
              'Preferred Language',
              userProgress.preferredLanguage,
              Icons.language,
            ),
            
            // Daily goal
            _buildProgressRow(
              'Daily Goal',
              '${userProgress.dailyGoal} minutes',
              Icons.timer,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements(UserProgress userProgress) {
    final achievements = _getAchievements(userProgress);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.amber.shade600),
                const SizedBox(width: 10),
                const Text(
                  'Achievements',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 15),
            
            if (achievements.isEmpty)
              Text(
                'Keep learning to unlock achievements!',
                style: TextStyle(color: Colors.grey.shade600),
              )
            else
              ...achievements.map((achievement) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Icon(
                        achievement['icon'],
                        color: achievement['color'],
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              achievement['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              achievement['description'],
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyHistory(UserProgress userProgress) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: Colors.purple.shade600),
                const SizedBox(width: 10),
                const Text(
                  'Study History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 15),
            
            if (userProgress.lastStudyDate != null) ...[
              Text(
                'Last Study Session:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                _formatDateTime(userProgress.lastStudyDate!),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
            ],
            
            Text(
              'Member Since:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            Text(
              _formatDateTime(userProgress.createdAt),
              style: const TextStyle(fontSize: 16),
            ),
            
            if (userProgress.hasStudiedToday) ...[
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade900,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.purpleAccent.shade100, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Studied today!',
                      style: TextStyle(
                        color: Colors.purpleAccent.shade100,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getAchievements(UserProgress userProgress) {
    List<Map<String, dynamic>> achievements = [];

    // First lesson achievement
    if (userProgress.totalLessonsCompleted >= 1) {
      achievements.add({
        'title': 'First Steps',
        'description': 'Completed your first lesson',
        'icon': Icons.school,
        'color': Colors.blue,
      });
    }

    // Streak achievements
    if (userProgress.currentStreak >= 3) {
      achievements.add({
        'title': 'Consistent Learner',
        'description': 'Maintained a 3-day streak',
        'icon': Icons.local_fire_department,
        'color': Colors.orange,
      });
    }

    if (userProgress.currentStreak >= 7) {
      achievements.add({
        'title': 'Week Warrior',
        'description': 'Maintained a 7-day streak',
        'icon': Icons.local_fire_department,
        'color': Colors.red,
      });
    }

    // XP achievements
    if (userProgress.totalXP >= 100) {
      achievements.add({
        'title': 'Rising Star',
        'description': 'Earned 100 XP',
        'icon': Icons.star,
        'color': Colors.amber,
      });
    }

    if (userProgress.totalXP >= 500) {
      achievements.add({
        'title': 'XP Master',
        'description': 'Earned 500 XP',
        'icon': Icons.stars,
        'color': Colors.purple,
      });
    }

    // Accuracy achievements
    if (userProgress.totalQuestionsAnswered >= 10 && userProgress.overallAccuracy >= 0.8) {
      achievements.add({
        'title': 'Sharp Shooter',
        'description': '80% accuracy on 10+ questions',
        'icon': Icons.track_changes,
        'color': Colors.green,
      });
    }

    return achievements;
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today at ${_formatTime(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${_formatTime(dateTime)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}