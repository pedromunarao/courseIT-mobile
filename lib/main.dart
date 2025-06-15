import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/create_account_screen.dart';

void main() {
  runApp(const CourseITApp());
}

class CourseITApp extends StatelessWidget {
  const CourseITApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'courseIT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/create': (context) => const CreateAccountScreen(),
      },
    );
  }
}
