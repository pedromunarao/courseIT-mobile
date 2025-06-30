import 'package:courseit/widgets/base_page.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class EnrollmentPage extends StatefulWidget {
  const EnrollmentPage({super.key});
  @override
  State<EnrollmentPage> createState() => _EnrollmentPageState();
}

class _EnrollmentPageState extends State<EnrollmentPage> {
  List<dynamic> courses = [];
  String? errorMessage;
  bool loading = true;
  int? selectedCourseId;
  bool enrolling = false;
  String? successMessage;
  final userId = AuthService.user?['id'];

  Future<void> fetchCourses() async {
    setState(() {
      loading = true;
      errorMessage = null;
      successMessage = null;
    });
    try {
      final data = await ApiService.getUserEnrollments(userId);
      setState(() => courses = data);
    } catch (e) {
      setState(() => errorMessage = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> enroll() async {
    if (selectedCourseId == null) {
      setState(() => errorMessage = 'Selecione um curso');
      return;
    }
    setState(() {
      enrolling = true;
      errorMessage = null;
      successMessage = null;
    });
    try {
      final response = await ApiService.enrollUser(
        AuthService.user!['id'],
        selectedCourseId!.toString(),
      );

      setState(
        () => successMessage = response['message'] ?? 'Matriculado com sucesso',
      );
    } catch (e) {
      setState(() => errorMessage = e.toString());
    } finally {
      setState(() => enrolling = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Minhas Matrículas',
      currentIndex: 2,
      child:
          loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButton<int>(
                      isExpanded: true,
                      hint: const Text('Selecione um curso'),
                      value: selectedCourseId,
                      items:
                          courses.map((course) {
                            return DropdownMenuItem<int>(
                              value: course['id'],
                              child: Text(course['title']),
                            );
                          }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedCourseId = val;
                          errorMessage = null;
                          successMessage = null;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: enrolling ? null : enroll,
                      child:
                          enrolling
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text('Matricular'),
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                    if (successMessage != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        successMessage!,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ],
                  ],
                ),
              ),
    );
  }
}
