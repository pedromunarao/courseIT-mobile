import 'package:courseit/services/auth_service.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/course_card.dart';
import '../widgets/base_page.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  List<dynamic> _courses = [];
  List<dynamic> _filteredCourses = [];
  bool isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (!AuthService.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
    } else {
      loadCourses();
    }
  }

  Future<void> loadCourses() async {
    try {
      final data = await ApiService.getAllCourses();
      print("AQUII  $data");
      setState(() {
        _courses = data;
        _filteredCourses = data;
      });
    } catch (e) {
      print("error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar cursos: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _searchCourses(String query) {
    final filtered =
        _courses.where((course) {
          final title = course['title'].toString().toLowerCase();
          return title.contains(query.toLowerCase());
        }).toList();
    setState(() {
      _searchQuery = query;
      _filteredCourses = filtered;
    });
  }

  void _openCourseDetails(Map<String, dynamic> course) {
    Navigator.pushNamed(context, '/course-details', arguments: course['id']);
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Cursos',
      currentIndex: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar cursos...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: _searchCourses,
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredCourses.isEmpty
                      ? const Center(child: Text('Nenhum curso encontrado.'))
                      : ListView.separated(
                        itemCount: _filteredCourses.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final course = _filteredCourses[index];
                          return GestureDetector(
                            onTap: () => _openCourseDetails(course),
                            child: CourseCard(course: course),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
