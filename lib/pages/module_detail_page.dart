import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/api_service.dart';
import '../widgets/base_page.dart';

class ModuleDetailsPage extends StatefulWidget {
  final String moduleId;
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/create-lessons'),
        child: const Icon(Icons.add),
      ),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : module == null
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
                        'Módulo não encontrado',
                        style: TextStyle(
                            fontSize: 25, color: Colors.deepPurple),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
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
                      if ((module!['lessons'] as List).isEmpty)
                        const Text('Nenhuma aula cadastrada.')
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: (module!['lessons'] as List).length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final lesson = module!['lessons'][index];
                            return ListTile(
                              title: Text(lesson['title']),
                              subtitle:
                                  Text(lesson['type'] ?? 'Conteúdo'),
                              onTap: () => _openLesson(lesson['id']),
                              trailing: const Icon(Icons.chevron_right),
                            );
                          },
                        ),
                    ],
                  ),
                ),
    );
  }
}
