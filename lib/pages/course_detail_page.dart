import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/base_page.dart';

class CourseDetailsPage extends StatefulWidget {
  final int courseId;

  const CourseDetailsPage({super.key, required this.courseId});

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  Map<String, dynamic>? course;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCourseDetails();
  }

  Future<void> fetchCourseDetails() async {
    try {
      final data = await ApiService.getCourseById(widget.courseId);
      setState(() {
        course = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar detalhes: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Detalhes do Curso',
      currentIndex: 1,
      child:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : course == null
              ? const Center(child: Text('Curso não encontrado.'))
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course!['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      course!['description'] ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Módulos:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.separated(
                        itemCount: (course!['modules'] as List).length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final module = course!['modules'][index];
                          return ListTile(
                            title: Text(module['title']),
                            onTap:
                                () => Navigator.pushNamed(
                                  context,
                                  '/module-details',
                                  arguments: module['id'],
                                ),
                            trailing: const Icon(Icons.chevron_right),
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
