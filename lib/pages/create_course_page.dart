import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class CreateCoursePage extends StatefulWidget {
  const CreateCoursePage({super.key});
  @override
  State<CreateCoursePage> createState() => _CreateCoursePageState();
}

class _CreateCoursePageState extends State<CreateCoursePage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  String? errorMessage;
  bool loading = false;

  Future<void> createCourse() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });
    try {
      final response = await ApiService.createCourse(
        titleController.text,
        descriptionController.text,
        AuthService.user!['id'].toString(),
      );

      print(response);

      Navigator.pop(context);
    } catch (e) {
      setState(() => errorMessage = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Curso')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : createCourse,
              child:
                  loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Criar'),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
