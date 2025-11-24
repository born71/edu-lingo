import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/progress_provider.dart';
import '../widgets/base_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Settings',
      currentRoute: '/settings',
      body: const SettingsScreenContent(),
    );
  }
}

class SettingsScreenContent extends StatelessWidget {
  const SettingsScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressProvider>(
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
              Navigator.pushReplacementNamed(context, '/'); // Go back to home
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}