import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/base_page.dart';

class ModuleDetailsPage extends StatefulWidget {
  final int moduleId;
  const ModuleDetailsPage({super.key, required this.moduleId});

  @override
  State<ModuleDetailsPage> createState() => _ModuleDetailsPageState();
}

class _ModuleDetailsPageState extends State<ModuleDetailsPage> {
  Map<String, dynamic>? module;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchModuleDetails();
  }

  Future<void> fetchModuleDetails() async {
    try {
      final data = await ApiService.getModuleById(widget.moduleId);
      setState(() {
        module = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar módulo: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _openLesson(int lessonId) {
    Navigator.pushNamed(context, '/lesson-details', arguments: lessonId);
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Detalhes do Módulo',
      currentIndex: 1,
      child:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : module == null
              ? const Center(child: Text('Módulo não encontrado.'))
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module!['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Aulas:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.separated(
                        itemCount: (module!['lessons'] as List).length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final lesson = module!['lessons'][index];
                          return ListTile(
                            title: Text(lesson['title']),
                            subtitle: Text(lesson['type'] ?? 'conteúdo'),
                            onTap: () => _openLesson(lesson['id']),
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
