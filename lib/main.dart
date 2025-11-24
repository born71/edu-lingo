import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/progress_provider.dart';
import 'widgets/main_layout.dart';
import 'screens/lesson_screen.dart';
import 'screens/stat_screen.dart';
import 'screens/settings_screen.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage service
  await StorageService.init();
  
  runApp(const LanguageLearningApp());
}

class LanguageLearningApp extends StatelessWidget {
  const LanguageLearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProgressProvider()..initialize(),
      child: MaterialApp(
        title: 'Edu-Lingo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          primaryColor: Colors.green.shade700,
          hintColor: Colors.orange,
          fontFamily: 'Inter',
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const MainLayout(),
          '/lesson': (context) => const LessonScreen(),
          '/stats': (context) => const StatsScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}