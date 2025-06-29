import 'package:courseit/pages/create_course_page.dart';
import 'package:courseit/pages/create_edit_module_page.dart' show CreateEditModulePage;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';
class ModuleDetailsPage extends StatelessWidget {
  final String moduleId;

  const ModuleDetailsPage({super.key, required this.moduleId});

  @override
  Widget build(BuildContext context) {
    // Carregar os detalhes do módulo usando `moduleId`
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Módulo'),
      ),
      body: FutureBuilder(
        future: ApiService.getModuleById(moduleId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final module = snapshot.data;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(module?['title'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(module?['description'] ?? '', style: const TextStyle(fontSize: 16)),
                // Adicione outros detalhes conforme necessário
              ],
            ),
          );
        },
      ),
    );
  }
}
