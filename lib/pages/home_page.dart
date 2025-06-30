import 'package:courseit/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/api_service.dart';
import '../widgets/base_page.dart';
import '../widgets/course_home_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> courses = [];
  bool loading = true;

  List<dynamic> featuredCourses = [];
  List<dynamic> recommendedCourses = [];
  List<dynamic> newCourses = [];

  @override
  void initState() {
    super.initState();

    fetchCurrentUser();

    if (!AuthService.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
    } else {
      loadCourses();
    }
  }

  Future<void> fetchCurrentUser() async {
    final res = await ApiService.getCurrentUser();
    print("MEU USER: $res");
  }

  Future<void> loadCourses() async {
    try {
      final data = await ApiService.getAllCourses();

      // Distribui os cursos entre as seções
      final first2 = data.take(2).toList();
      final next2 = data.skip(2).take(2).toList();
      final next2Again = data.skip(4).take(2).toList();

      setState(() {
        courses = data;
        featuredCourses = first2;
        recommendedCourses = next2;
        newCourses = next2Again;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar cursos: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Home',
      currentIndex: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child:
            loading
                ? const Center(child: CircularProgressIndicator())
                : courses.isEmpty
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/animations/animation_not_found.json',
                      height: 300,
                      fit: BoxFit.fill,
                    ),
                    const Text(
                      'Nenhum curso encontrado.',
                      style: TextStyle(fontSize: 20, color: Colors.deepPurple),
                    ),
                  ],
                )
                : SingleChildScrollView(
                  child: Column(
                    children: [
                      buildSection('Cursos em Destaque', featuredCourses),
                      buildSection('Recomendados', recommendedCourses),
                      buildSection('Lançamentos', newCourses),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget buildSection(String title, List<dynamic> sectionCourses) {
    if (sectionCourses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: sectionCourses.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final course = sectionCourses[index];
              return CourseHomeCard(
                course: course,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/course-details',
                    arguments: course['id'],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
