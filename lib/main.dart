// Simple Duolingo-style Learning App in Flutter (main.dart)
import 'package:flutter/material.dart';

// 1. เพิ่ม Route สำหรับ StatsScreen (จำเป็นต้องคงไว้แม้ว่าจะแยกไฟล์ก็ตาม)
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Learning Stats'),
        backgroundColor: Colors.blueGrey,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.analytics,
                size: 80,
                color: Colors.blueGrey,
              ),
              const SizedBox(height: 20),
              const Text(
                'Progress Overview',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              // Card แสดงผลสถิติจำลอง
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: const ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: Text('Lessons Completed'),
                  trailing: Text('12', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: const ListTile(
                  leading: Icon(Icons.star, color: Colors.amber),
                  title: Text('Current Streak'),
                  trailing: Text('5 Days', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 30),
              // ปุ่มย้อนกลับ
              ElevatedButton(
                onPressed: () {
                  // ใช้ Navigator.pop เพื่อย้อนกลับไปยังหน้าจอก่อนหน้า
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Go Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// --- 1. Data Model ---
// Define a simple class to hold our quiz data.
class QuizQuestion {
  final String question;
  final String correctAnswer;
  final List<String> options;

  QuizQuestion({
    required this.question,
    required this.correctAnswer,
    required this.options,
  });
}

// Global list of lesson data
final List<QuizQuestion> lessonData = [
  QuizQuestion(
    question: 'Select the Spanish word for "Hello"',
    correctAnswer: 'Hola',
    options: ['Guten Tag', 'Bonjour', 'Hola', 'Ciao'],
  ),
  QuizQuestion(
    question: 'How do you say "Thank you" in French?',
    correctAnswer: 'Merci',
    options: ['Danke', 'Merci', 'Gracias', 'Arigato'],
  ),
  QuizQuestion(
    question: 'What is the German word for "Water"?',
    correctAnswer: 'Wasser',
    options: ['Agua', 'Eau', 'Wasser', 'Mizu'],
  ),
];

// --- 2. Main Application Setup ---
void main() {
  runApp(const LanguageLearningApp());
}

class LanguageLearningApp extends StatelessWidget {
  const LanguageLearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp sets up the base of the Flutter application
    return MaterialApp(
      title: 'Edu-Lingo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Use a vibrant green color theme, similar to educational apps
        primarySwatch: Colors.green,
        primaryColor: Colors.green.shade700,
        hintColor: Colors.orange,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      // Define the application routes
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/lesson': (context) => const LessonScreen(),
        // เพิ่ม Route ใหม่สำหรับหน้าสถิติ: ใช้ชื่อเส้นทาง '/stats'
        '/stats': (context) => const StatsScreen(), 
      },
    );
  }
}

// --- 3. Home Screen (Start Page) ---
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edu-Lingo Home'),
        backgroundColor: Colors.green.shade400,
        elevation: 0,
        // **ลบ actions: [...] ออก** เพื่อให้ปุ่มเมนู (hamburger icon) ที่เปิด Drawer ปรากฏขึ้นมาอัตโนมัติ
      ),
      // **เพิ่ม Drawer Widget**
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // 1. DrawerHeader: ส่วนหัวของ Drawer
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
            // 2. ListTile: เมนูสำหรับหน้าหลัก
            ListTile(
              leading: const Icon(Icons.home, color: Colors.green),
              title: const Text('Home'),
              onTap: () {
                // ปิด Drawer แล้วกลับไปที่หน้า Home (root route)
                Navigator.pop(context); // ปิด Drawer
                Navigator.pushNamed(context, '/');
              },
            ),
            // 3. ListTile: เมนูสำหรับเริ่มบทเรียน
            ListTile(
              leading: const Icon(Icons.play_circle_fill, color: Colors.orange),
              title: const Text('Start Lesson'),
              onTap: () {
                // ปิด Drawer แล้วนำทางไปยัง LessonScreen
                Navigator.pop(context); // ปิด Drawer
                Navigator.pushNamed(context, '/lesson');
              },
            ),
            // 4. ListTile: เมนูสำหรับดูสถิติ (แทนที่ปุ่มบน AppBar เดิม)
            ListTile(
              leading: const Icon(Icons.analytics, color: Colors.blueGrey),
              title: const Text('Your Progress & Stats'),
              onTap: () {
                // ปิด Drawer แล้วนำทางไปยัง StatsScreen
                Navigator.pop(context); // ปิด Drawer
                Navigator.pushNamed(context, '/stats');
              },
            ),
            const Divider(), // เส้นแบ่ง
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.grey),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context); // ปิด Drawer (ยังไม่มีหน้า Settings)
                // สามารถเพิ่ม Navigator.pushNamed(context, '/settings'); ในอนาคต
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
              const SizedBox(height: 40),

              // Course Card Example (Simulates a single module)
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Module 1: Basic Greetings',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      const LinearProgressIndicator(
                        value: 0.33, // Example progress
                        color: Colors.green,
                        minHeight: 8,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      const SizedBox(height: 5),
                      Text('Progress: 33%', style: TextStyle(color: Colors.grey.shade600)),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to the LessonScreen when button is pressed
                          Navigator.pushNamed(context, '/lesson');
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start Lesson'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 4. Lesson Screen (Quiz Logic) ---
class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  // State variables to manage the quiz flow
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  bool _isAnswerChecked = false;
  String? _feedbackMessage;
  Color _feedbackColor = Colors.transparent;

  // Get the current question object
  QuizQuestion get currentQuestion => lessonData[_currentQuestionIndex];

  // Function to handle when an option button is tapped
  void _handleAnswer(String answer) {
    if (_isAnswerChecked) return; // Prevent multiple selections

    setState(() {
      _selectedAnswer = answer;
    });
  }

  // Function to check the selected answer against the correct one
  void _checkAnswer() {
    if (_selectedAnswer == null) {
      // Show a message if no answer is selected
      _showSimpleMessage(
          'Please select an answer first.', Colors.orange.shade800);
      return;
    }

    setState(() {
      _isAnswerChecked = true;
      if (_selectedAnswer == currentQuestion.correctAnswer) {
        _feedbackMessage = 'Correct! Great job.';
        _feedbackColor = Colors.green.shade600;
      } else {
        _feedbackMessage =
            'Incorrect. The correct answer was "${currentQuestion.correctAnswer}"';
        _feedbackColor = Colors.red.shade600;
      }
    });
  }

  // Function to move to the next question or finish the lesson
  void _nextQuestion() {
    // Reset state for the next question
    setState(() {
      _isAnswerChecked = false;
      _selectedAnswer = null;
      _feedbackMessage = null;
      _feedbackColor = Colors.transparent;
      _currentQuestionIndex++;
    });

    // Check if the lesson is finished
    if (_currentQuestionIndex >= lessonData.length) {
      _showSimpleMessage('Lesson Complete! You finished all the questions.',
          Colors.blue.shade600);
      // Navigate back to the home screen after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    }
  }

  // Helper function to show a simple floating message (like a Snackbar)
  void _showSimpleMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the current progress as a percentage
    final double progress = (_currentQuestionIndex + 1) / lessonData.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson: Basic Greetings'),
        backgroundColor: Colors.green.shade400,
      ),
      body: Column(
        children: <Widget>[
          // Progress Bar at the top
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade300,
              color: Colors.amber,
              minHeight: 10,
              borderRadius: const BorderRadius.all(Radius.circular(5)),
            ),
          ),

          // Question Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Question ${_currentQuestionIndex + 1} of ${lessonData.length}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 10),
                  // The main question text
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Text(
                      currentQuestion.question,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Option Buttons
                  ...currentQuestion.options.map((option) {
                    // Determine the color and border of the option button
                    Color buttonColor = Colors.white;
                    Color borderColor = Colors.grey.shade300;
                    Color textColor = Colors.black87;

                    if (_isAnswerChecked) {
                      // If checked, highlight correct/incorrect answers
                      if (option == currentQuestion.correctAnswer) {
                        borderColor = Colors.green.shade600;
                        buttonColor = Colors.green.shade50;
                      } else if (option == _selectedAnswer) {
                        borderColor = Colors.red.shade600;
                        buttonColor = Colors.red.shade50;
                      }
                    } else if (option == _selectedAnswer) {
                      // If not checked, just highlight the selected option
                      borderColor = Colors.blue.shade600;
                      buttonColor = Colors.blue.shade50;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: OutlinedButton(
                        onPressed: () => _handleAnswer(option),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: buttonColor,
                          side: BorderSide(color: borderColor, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),

          // --- Feedback and Action Bar (Bottom of Screen) ---
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: _isAnswerChecked ? _feedbackColor.withOpacity(0.9) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Show feedback message if the answer has been checked
                  if (_feedbackMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        _feedbackMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                  // Primary Action Button
                  ElevatedButton(
                    onPressed: _selectedAnswer == null && !_isAnswerChecked
                        ? null // Disable if nothing is selected and not checked
                        : _isAnswerChecked
                            ? _nextQuestion // If checked, move to next
                            : _checkAnswer, // If not checked, check answer
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      backgroundColor: _isAnswerChecked
                          ? Colors.blue.shade600 // 'Continue' button color
                          : Colors.green.shade600, // 'Check' button color
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: Text(
                      _isAnswerChecked ? 'CONTINUE' : 'CHECK ANSWER',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}