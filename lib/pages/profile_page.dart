import 'package:courseit/widgets/base_page.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? user;
  String? errorMessage;
  bool loading = true;
  final userId = AuthService.user?['id'];

  Future<void> fetchProfile() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });
    try {
      final data = await ApiService.getCurrentUser();
      setState(() => user = data);
    } catch (e) {
      setState(() => errorMessage = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  void logout() {
    AuthService.clearSession();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.user;

    return BasePage(
      title: 'Perfil',
      currentIndex: 2,
      child:
          user == null
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
                      'Usuário não encontrado',
                      style: TextStyle(fontSize: 25, color: Colors.deepPurple),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.only(left: 24, right: 24),
                child: Column(
                  children: [
                    Lottie.asset(
                      'assets/animations/animation_user.json',
                      width: 300,
                      fit: BoxFit.fill,
                    ),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Column(
                          children: [
                            // Nome
                            Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  color: Colors.deepPurple,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    user['name'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 32, thickness: 1),
                            // Email
                            Row(
                              children: [
                                const Icon(
                                  Icons.email,
                                  color: Colors.deepPurple,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    user['email'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.list_alt),
                        label: const Text('Meus Cursos'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/my-courses');
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.list_alt),
                        label: const Text('Deletar Conta'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        onPressed: () async {
                          try {
                            final response = await ApiService.deleteUser();
                            print("User deleted: $response");

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Usuário deletado com sucesso!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            print("Erro ao deletar usuário: $e");
                          }
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
