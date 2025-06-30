import 'dart:io';
import 'package:courseit/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/api_service.dart';
import '../widgets/base_page.dart';

class CourseDetailsPage extends StatefulWidget {
  final String courseId;

  const CourseDetailsPage({super.key, required this.courseId});

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  Map<String, dynamic>? course;
  bool isLoading = true;
  final bool isUserAdmin = AuthService.isUserAdmin;

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
                      'Curso não encontrado',
                      style: TextStyle(fontSize: 25, color: Colors.deepPurple),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // IMAGEM DO CURSO
                    if (course!['imageUrl'] != null &&
                        (course!['imageUrl'] as String).isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildImage(course!['imageUrl']),
                      )
                    else
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/logo.png',
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 16),

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

                    (course!['modules'] == null ||
                            (course!['modules'] as List).isEmpty)
                        ? Center(
                          child: Lottie.asset(
                            'assets/animations/animation_not_found.json',
                            width: 200,
                            height: 200,
                            fit: BoxFit.fill,
                          ),
                        )
                        : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: (course!['modules'] as List).length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final module = (course!['modules'] as List)[index];
                            return ListTile(
                              title: Text(module['title']),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/module-details',
                                  arguments: module['id'],
                                );
                              },
                              trailing: const Icon(Icons.chevron_right),
                            );
                          },
                        ),

                    if (isUserAdmin)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: ElevatedButton(
                          onPressed:
                              () => Navigator.pushNamed(
                                context,
                                '/create-module',
                              ),
                          child: const Text('Adicionar Módulo'),
                        ),
                      ),
                  ],
                ),
              ),
    );
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      print("Image.network : $imageUrl");
      return Image.network(
        imageUrl,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          print("Erro ao carregar imagem da URL: $error");
          return Image.asset(
            'assets/logo.png',
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          );
        },
      );
    } else {
      print("Image.file : $imageUrl");
      final file = File(imageUrl);
      if (file.existsSync()) {
        return Image.file(
          file,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      } else {
        return Image.asset(
          'assets/logo.png',
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      }
    }
  }
}
