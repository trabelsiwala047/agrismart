import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:agrismart/firebase_options.dart';
import 'package:agrismart/providers/auth_provider.dart';
import 'package:agrismart/providers/zones_provider.dart';
import 'package:agrismart/providers/meteo_provider.dart';
import 'package:agrismart/services/firebase_auth_service.dart';
import 'package:agrismart/app.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final authService = FirebaseAuthService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
        ChangeNotifierProvider(create: (_) => ZonesProvider()),
        ChangeNotifierProvider(create: (_) => MeteoProvider()..charger()),
      ],
      child: const MyApp(),
    ),
  );
}