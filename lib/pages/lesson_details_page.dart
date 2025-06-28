import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/base_page.dart';

class LessonDetailsPage extends StatefulWidget {
  final int lessonId;
  const LessonDetailsPage({super.key, required this.lessonId});

  @override
  State<LessonDetailsPage> createState() => _LessonDetailsPageState();
}

class _LessonDetailsPageState extends State<LessonDetailsPage> {
  Map<String, dynamic>? lesson;
  bool isLoading = true;
  bool markingProgress = false;

  @override
  void initState() {
    super.initState();
    fetchLesson();
  }

  Future<void> fetchLesson() async {
    try {
      final data = await ApiService.getLessonById(widget.lessonId.toString());
      setState(() {
        lesson = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar aula: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> markProgress() async {
    setState(() => markingProgress = true);
    try {
      final userId = AuthService.user?['id'];
      if (userId != null && lesson != null) {
        await ApiService.postProgress({
          'userId': userId,
          'lessonId': lesson!['id'],
          'status': 'completed',
        });
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Progresso registrado!')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao registrar progresso: $e')),
      );
    } finally {
      setState(() => markingProgress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Detalhes da Aula',
      currentIndex: 1,
      child:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : lesson == null
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
                      'Aula não encontrada',
                      style: TextStyle(fontSize: 25, color: Colors.deepPurple),
                    ),
                  ],
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson!['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      lesson!['content'] ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    if (lesson!['videoUrl'] != null)
                      Text('Vídeo: ${lesson!['videoUrl']}'),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: markingProgress ? null : markProgress,
                        child:
                            markingProgress
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text('Marcar como concluída'),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
