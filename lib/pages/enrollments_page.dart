// lib/pages/enrollments_page.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/api_service.dart';

class EnrollmentsPage extends StatefulWidget {
  const EnrollmentsPage({super.key});

  @override
  State<EnrollmentsPage> createState() => _EnrollmentsPageState();
}

class _EnrollmentsPageState extends State<EnrollmentsPage> {
  List<dynamic> enrollments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEnrollments();
  }

  Future<void> fetchEnrollments() async {
    try {
      final user = await ApiService.getCurrentUser();
      final data = await ApiService.getUserEnrollments(user['id']);
      setState(() => enrollments = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar matrículas: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Matrículas')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : enrollments.isEmpty
              ? Column(
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
                    'Nenhuma matrícula encontrada.',
                    style: TextStyle(fontSize: 20, color: Colors.deepPurple),
                  ),
                ],
              )
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: enrollments.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final item = enrollments[index];
                  return ListTile(
                    title: Text('Curso ID: ${item['courseId']}'),
                    subtitle: Text(
                      'Progresso: ${item['progress'] ?? 'indefinido'}',
                    ),
                  );
                },
              ),
    );
  }
}
