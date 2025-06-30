import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/api_service.dart';
import '../widgets/course_card.dart';
import '../widgets/base_page.dart';

class MyCoursesPage extends StatefulWidget {
  const MyCoursesPage({super.key});

  @override
  State<MyCoursesPage> createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends State<MyCoursesPage> {
  List<dynamic> _courses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMyCourses();
  }

  Future<void> loadMyCourses() async {
    try {
      final response = await ApiService.getMyCourses();
      setState(() {
        _courses = response;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar seus cursos: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _openCourseDetails(Map<String, dynamic> course) {
    Navigator.pushNamed(context, '/course-details', arguments: course['id']);
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Meus Cursos',
      currentIndex: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : _courses.isEmpty
                ? Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/animations/animation_not_found.json',
                        width: 300,
                        height: 300,
                        fit: BoxFit.fill,
                      ),
                      const Text(
                        'Você ainda não possui cursos cadastrados.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.deepPurple,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
                : ListView.separated(
                  itemCount: _courses.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final course = _courses[index];
                    return GestureDetector(
                      onTap: () => _openCourseDetails(course),
                      child: CourseCard(course: course),
                    );
                  },
                ),
      ),
    );
  }
}
