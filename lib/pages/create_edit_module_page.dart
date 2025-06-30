import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class CreateEditModulePage extends StatefulWidget {
  final String? moduleId; // Se for nulo, estamos criando um novo módulo
  final String? currentTitle; // O título atual para edição

  const CreateEditModulePage({super.key, this.moduleId, this.currentTitle});

  @override
  State<CreateEditModulePage> createState() => _CreateEditModulePageState();
}

class _CreateEditModulePageState extends State<CreateEditModulePage> {
  final titleController = TextEditingController();
  String? errorMessage;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    // Se estamos editando, preenche o título com o valor atual
    if (widget.moduleId != null && widget.currentTitle != null) {
      titleController.text = widget.currentTitle!;
    }
  }

  Future<void> saveModule() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final response =
          widget.moduleId == null
              ? await ApiService.createModule(
                titleController.text,
                AuthService.user!['id'].toString(),
              )
              : await ApiService.updateModule(
                widget.moduleId!,
                titleController.text,
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
      appBar: AppBar(
        title: Text(widget.moduleId == null ? 'Criar Módulo' : 'Editar Módulo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Lottie.asset(
              'assets/animations/animation_create_course.json', // Animacao para criação de módulo
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
                'Preencha as informações do módulo e seja capaz de ensinar de forma eficaz.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Título do Módulo'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : saveModule,
              child:
                  loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                        widget.moduleId == null
                            ? 'Criar Módulo'
                            : 'Salvar Módulo',
                      ),
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
