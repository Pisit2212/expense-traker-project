import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

import 'theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final themeController = ThemeController();
  await themeController.init();
  runApp(
    ChangeNotifierProvider.value(
      value: themeController,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeController.mode,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authState,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        return snapshot.hasData ? const HomeScreen() : const LoginScreen();
      },
    );
  }
}