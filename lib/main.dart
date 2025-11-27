import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/progress_provider.dart';
import 'providers/auth_provider.dart';
import 'widgets/main_layout.dart';
import 'screens/lesson_screen.dart';
import 'screens/stat_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/api_test_screen.dart';
import 'services/storage_service.dart';
import 'utils/page_transitions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize storage service
  await StorageService.init();
  
  runApp(const LanguageLearningApp());
}

class LanguageLearningApp extends StatelessWidget {
  const LanguageLearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()..initialize()),
      ],
      child: MaterialApp(
        title: 'Edu-Lingo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.deepPurple,
          primaryColor: Colors.deepPurple.shade400,
          scaffoldBackgroundColor: const Color(0xFF121212),
          cardColor: const Color(0xFF1E1E2E),
          hintColor: Colors.amber,
          fontFamily: 'Inter',
          useMaterial3: true,
          colorScheme: ColorScheme.dark(
            primary: Colors.deepPurple.shade400,
            secondary: Colors.purpleAccent.shade100,
            surface: const Color(0xFF1E1E2E),
            background: const Color(0xFF121212),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xFF1E1E2E),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            color: const Color(0xFF1E1E2E),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple.shade400,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        initialRoute: '/splash',
        onGenerateRoute: (settings) {
          // Custom page transitions for routes
          switch (settings.name) {
            case '/splash':
              return FadeSlideRoute(page: const SplashScreen());
            case '/':
              return FadeSlideRoute(page: const MainLayout());
            case '/lesson':
              return SlideRightRoute(page: const LessonScreen());
            case '/stats':
              return FadeSlideRoute(page: const StatsScreen());
            case '/settings':
              return FadeSlideRoute(page: const SettingsScreen());
            case '/profile':
              return SlideRightRoute(page: const ProfileScreen());
            case '/login':
              return FadeSlideRoute(page: const LoginScreen());
            case '/register':
              return SlideRightRoute(page: const RegisterScreen());
            case '/api-test':
              return FadeSlideRoute(page: const ApiTestScreen());
            default:
              return FadeSlideRoute(page: const MainLayout());
          }
        },
      ),
    );
  }
}