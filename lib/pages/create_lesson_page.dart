import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/api_service.dart';

class CreateLessonPage extends StatefulWidget {
  final String moduleId;
  const CreateLessonPage({super.key, required this.moduleId});

  @override
  State<CreateLessonPage> createState() => _CreateLessonPageState();
}

class _CreateLessonPageState extends State<CreateLessonPage> {
  final titleController = TextEditingController();
  final orderController = TextEditingController();
  final contentController = TextEditingController();
  final videoUrlController = TextEditingController();

  String? errorMessage;
  bool loading = false;

  Future<void> createLesson() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiService.createLesson(
        title: titleController.text,
        order: int.tryParse(orderController.text) ?? 1,
        content: contentController.text,
        moduleId: widget.moduleId.toString(),
        videoUrl: videoUrlController.text.isNotEmpty
            ? videoUrlController.text
            : null,
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
      appBar: AppBar(title: const Text('Criar Aula')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Lottie.asset(
                'assets/animations/animation_create_course.json',
                height: 200,
                fit: BoxFit.fill,
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Crie sua aula com as informações necessárias para o seu módulo.',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Título da Aula'),
              ),
              TextField(
                controller: orderController,
                decoration:
                    const InputDecoration(labelText: 'Ordem da Aula'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Conteúdo'),
                maxLines: 3,
              ),
              TextField(
                controller: videoUrlController,
                decoration:
                    const InputDecoration(labelText: 'URL do Vídeo (opcional)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: loading ? null : createLesson,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Criar Aula'),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(errorMessage!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
