import 'package:courseit/services/auth_service.dart';
import 'package:courseit/services/routes.dart';
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final loggedIn = AuthService.isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plataforma Educacional',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute:
          loggedIn ? (AuthService.isUserAdmin ? '/home' : '/courses') : '/',
      onGenerateRoute: generateRoute,
    );
  }
}
