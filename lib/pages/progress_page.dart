// lib/pages/progress_page.dart
import 'package:courseit/services/auth_service.dart';
import 'package:courseit/widgets/base_page.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  List<dynamic> progressList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  Future<void> loadProgress() async {
    try {
      final userId = AuthService.user?['id'];
      final progress = await ApiService.getUserProgress(userId);
      setState(() => progressList = progress);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar progresso: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Meu Progresso',
      currentIndex: 2,
      child:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : progressList.isEmpty
              ? const Center(child: Text('Nenhum progresso encontrado.'))
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: progressList.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final item = progressList[index];
                  return ListTile(
                    title: Text('Aula ID: ${item['lessonId']}'),
                    subtitle: Text('Status: ${item['status']}'),
                  );
                },
              ),
    );
  }
}
