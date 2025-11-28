import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/progress_provider.dart';
import '../models/lesson.dart';
import '../widgets/base_scaffold.dart';
import '../widgets/data_source_indicator.dart';
import '../widgets/animated_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Edulingo',
      currentRoute: '/',
      body: const HomeScreenContent(),
    );
  }
}

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressProvider>(
        builder: (context, progressProvider, child) {
          if (progressProvider.isLoading) {
            return const LoadingOverlay(message: 'Loading lessons...');
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
                  color: Colors.deepPurple.shade300,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Ready to Learn a New Language?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
                                 color: Colors.deepPurple.shade300),
                            const SizedBox(width: 10),
                            const Text(
                              'Your Progress',
                              style: TextStyle(
                                fontSize: 18, 
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        LinearProgressIndicator(
                          value: progressProvider.overallProgress,
                          color: Colors.deepPurple.shade300,
                          backgroundColor: Colors.grey.shade800,
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

                // Available Lessons with Data Source Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Available Lessons',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        DataSourceIndicator(
                          source: progressProvider.dataSource,
                          isLoading: progressProvider.isLoading,
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => progressProvider.refreshLessonsFromApi(),
                          icon: Icon(
                            Icons.refresh,
                            color: Colors.deepPurple.shade300,
                          ),
                          tooltip: 'Refresh from API',
                        ),
                      ],
                    ),
                  ],
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
                                    color: Colors.purpleAccent.shade100,
                                    size: 30,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            
                            if (progress > 0) ...[
                              LinearProgressIndicator(
                                value: progress,
                                color: isCompleted ? Colors.purpleAccent.shade100 : Colors.deepPurple.shade300,
                                backgroundColor: Colors.grey.shade800,
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
                                          ? Colors.purple.shade400 
                                          : Colors.deepPurple.shade400,
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
}