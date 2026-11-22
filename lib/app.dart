import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agrismart/providers/reglages_provider.dart';
import 'package:agrismart/screens/auth_gate.dart';
import 'package:agrismart/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ReglagesProvider>().themeMode;
    return MaterialApp(
      title: 'AgriSmart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.clair(),
      darkTheme: AppTheme.sombre(),
      themeMode: themeMode,
      home: const AuthGate(),
    );
  }
}
