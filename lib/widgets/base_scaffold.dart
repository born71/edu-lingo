import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/progress_provider.dart';
import '../models/lesson.dart';

class BaseScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final String currentRoute;
  final PreferredSizeWidget? appBar;

  const BaseScaffold({
    super.key,
    required this.body,
    required this.title,
    required this.currentRoute,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar ?? AppBar(
        title: Text(title),
        backgroundColor: Colors.green.shade400,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: body,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.green.shade400,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              context: context,
              icon: Icons.home,
              label: 'Home',
              isActive: currentRoute == '/',
              onTap: () => _navigateToRoute(context, '/'),
            ),
            _buildNavItem(
              context: context,
              icon: Icons.play_circle_fill,
              label: 'Lessons',
              isActive: false,
              onTap: () => _showLessonSelection(context),
            ),
            // Logo in center
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.school,
                color: Colors.green.shade700,
                size: 32,
              ),
            ),
            _buildNavItem(
              context: context,
              icon: Icons.analytics,
              label: 'Stats',
              isActive: currentRoute == '/stats',
              onTap: () => _navigateToRoute(context, '/stats'),
            ),
            _buildNavItem(
              context: context,
              icon: Icons.settings,
              label: 'Settings',
              isActive: currentRoute == '/settings',
              onTap: () => _navigateToRoute(context, '/settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.white70,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToRoute(BuildContext context, String route) {
    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.pushReplacementNamed(context, route);
    }
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

  void _startLesson(BuildContext context, Lesson lesson) {
    Navigator.pushNamed(
      context, 
      '/lesson',
      arguments: lesson.id,
    );
  }
}