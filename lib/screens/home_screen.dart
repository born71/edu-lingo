import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/progress_provider.dart';
import '../models/lesson.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edu-Lingo Home'),
        backgroundColor: Colors.green.shade400,
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green.shade700,
              ),
              child: const Text(
                'Edu-Lingo Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.green),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/');
              },
            ),
            ListTile(
              leading: const Icon(Icons.play_circle_fill, color: Colors.orange),
              title: const Text('Start Lesson'),
              onTap: () {
                Navigator.pop(context);
                _showLessonSelection(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics, color: Colors.blueGrey),
              title: const Text('Your Progress & Stats'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/stats');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.grey),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                _showSettings(context);
              },
            ),
          ],
        ),
      ),
      body: Consumer<ProgressProvider>(
        builder: (context, progressProvider, child) {
          if (progressProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (progressProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${progressProvider.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => progressProvider.initialize(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Main title/logo area
                Icon(
                  Icons.school,
                  size: 80,
                  color: Colors.green.shade700,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Ready to Learn a New Language?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),

                // Overall Progress Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.trending_up, 
                                 color: Colors.green.shade600),
                            const SizedBox(width: 10),
                            const Text(
                              'Your Progress',
                              style: TextStyle(
                                fontSize: 18, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        LinearProgressIndicator(
                          value: progressProvider.overallProgress,
                          color: Colors.green,
                          backgroundColor: Colors.grey.shade300,
                          minHeight: 8,
                          borderRadius: const BorderRadius.all(Radius.circular(4)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${progressProvider.lessonsCompleted} of ${progressProvider.totalLessonsAvailable} lessons completed',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              'Streak', 
                              '${progressProvider.userProgress.currentStreak}',
                              Icons.local_fire_department,
                              Colors.orange
                            ),
                            _buildStatItem(
                              'XP', 
                              '${progressProvider.userProgress.totalXP}',
                              Icons.stars,
                              Colors.amber
                            ),
                            _buildStatItem(
                              'Accuracy', 
                              '${(progressProvider.userProgress.overallAccuracy * 100).toStringAsFixed(0)}%',
                              Icons.track_changes,
                              Colors.blue
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Available Lessons
                const Text(
                  'Available Lessons',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),

                ...progressProvider.lessons.map((lesson) {
                  final lessonProgress = progressProvider.getLessonProgress(lesson.id);
                  final isCompleted = lessonProgress?.isCompleted ?? false;
                  final progress = lessonProgress?.progressPercentage ?? 0.0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        lesson.title,
                                        style: const TextStyle(
                                          fontSize: 18, 
                                          fontWeight: FontWeight.w600
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        lesson.description,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isCompleted)
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green.shade600,
                                    size: 30,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            
                            if (progress > 0) ...[
                              LinearProgressIndicator(
                                value: progress,
                                color: isCompleted ? Colors.green : Colors.orange,
                                backgroundColor: Colors.grey.shade300,
                                minHeight: 6,
                                borderRadius: const BorderRadius.all(Radius.circular(3)),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Progress: ${(progress * 100).toInt()}%',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                              ),
                              const SizedBox(height: 15),
                            ] else ...[
                              const SizedBox(height: 10),
                            ],

                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _startLesson(context, lesson),
                                    icon: Icon(isCompleted ? Icons.replay : Icons.play_arrow),
                                    label: Text(isCompleted ? 'Review' : 'Start Lesson'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isCompleted 
                                          ? Colors.blue.shade600 
                                          : Colors.green.shade600,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${lesson.estimatedMinutes} min',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _startLesson(BuildContext context, Lesson lesson) {
    Navigator.pushNamed(
      context, 
      '/lesson',
      arguments: lesson.id,
    );
  }

  void _showLessonSelection(BuildContext context) {
    final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose a lesson',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            ...progressProvider.lessons.map((lesson) {
              return ListTile(
                title: Text(lesson.title),
                subtitle: Text(lesson.description),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.pop(context);
                  _startLesson(context, lesson);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.grey.shade700,
      ),
      body: Consumer<ProgressProvider>(
        builder: (context, progressProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Preferences',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      ListTile(
                        title: const Text('Preferred Language'),
                        subtitle: Text(progressProvider.userProgress.preferredLanguage),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => _showLanguageSelection(context),
                      ),
                      ListTile(
                        title: const Text('Daily Goal'),
                        subtitle: Text('${progressProvider.userProgress.dailyGoal} minutes'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => _showDailyGoalSelection(context),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Data',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      ListTile(
                        title: const Text('Reset All Progress'),
                        subtitle: const Text('This cannot be undone'),
                        trailing: const Icon(Icons.warning, color: Colors.red),
                        onTap: () => _showResetConfirmation(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLanguageSelection(BuildContext context) {
    final languages = ['Spanish', 'French', 'German', 'Italian', 'Portuguese'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Preferred Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((language) {
            return ListTile(
              title: Text(language),
              onTap: () {
                Provider.of<ProgressProvider>(context, listen: false)
                    .updatePreferredLanguage(language);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDailyGoalSelection(BuildContext context) {
    final goals = [5, 10, 15, 20, 30, 45, 60];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Daily Goal (minutes)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: goals.map((goal) {
            return ListTile(
              title: Text('$goal minutes'),
              onTap: () {
                Provider.of<ProgressProvider>(context, listen: false)
                    .updateDailyGoal(goal);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Progress?'),
        content: const Text(
          'This will permanently delete all your progress, stats, and preferences. This action cannot be undone.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ProgressProvider>(context, listen: false)
                  .resetAllProgress();
              Navigator.pop(context);
              Navigator.pop(context); // Go back to home
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}