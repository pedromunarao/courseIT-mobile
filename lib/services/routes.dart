import 'package:courseit/pages/course_detail_page.dart';
import 'package:courseit/pages/courses_page.dart';
import 'package:courseit/pages/create_course_page.dart';
import 'package:courseit/pages/enrollments_page.dart';
import 'package:courseit/pages/home_page.dart';
import 'package:courseit/pages/lesson_details_page.dart';
import 'package:courseit/pages/login_page.dart';
import 'package:courseit/pages/module_detail_page.dart';
import 'package:courseit/pages/profile_page.dart';
import 'package:courseit/pages/progress_page.dart';
import 'package:courseit/pages/register_page.dart';
import 'package:courseit/pages/welcome_page.dart';
import 'package:flutter/material.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => const WelcomePage());
    case '/home':
      return MaterialPageRoute(builder: (_) => const HomePage());
    case '/register':
      return MaterialPageRoute(builder: (_) => const RegisterPage());
    case '/login':
      return MaterialPageRoute(builder: (_) => const LoginPage());
    case '/courses':
      return MaterialPageRoute(builder: (_) => const CoursesPage());
    case '/course-details':
      final courseId = settings.arguments as int;
      return MaterialPageRoute(
        builder: (_) => CourseDetailsPage(courseId: courseId),
      );
    case '/module-details':
      final moduleId = settings.arguments as int;
      return MaterialPageRoute(
        builder: (_) => ModuleDetailsPage(moduleId: moduleId),
      );
    case '/lesson-details':
      final lessonId = settings.arguments as int;
      return MaterialPageRoute(
        builder: (_) => LessonDetailsPage(lessonId: lessonId),
      );
    case '/enrollments':
      return MaterialPageRoute(builder: (_) => const EnrollmentsPage());
    case '/create-course':
      return MaterialPageRoute(builder: (_) => const CreateCoursePage());
    case '/progress':
      return MaterialPageRoute(builder: (_) => const ProgressPage());
    case '/profile':
      return MaterialPageRoute(builder: (_) => const ProfilePage());
    default:
      return MaterialPageRoute(
        builder:
            (_) => Scaffold(
              appBar: AppBar(),
              body: const Center(child: Text('Rota não encontrada')),
            ),
      );
  }
}
