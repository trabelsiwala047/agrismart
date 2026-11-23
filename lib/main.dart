import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agrismart/firebase_options.dart';
import 'package:agrismart/providers/auth_provider.dart';
import 'package:agrismart/providers/reglages_provider.dart';
import 'package:agrismart/providers/zones_provider.dart';
import 'package:agrismart/providers/meteo_provider.dart';
import 'package:agrismart/providers/translation_provider.dart'; // jdid
import 'package:agrismart/services/firebase_auth_service.dart';
import 'package:agrismart/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final authService = FirebaseAuthService();

  // Stockage local: yetefta7 mara wahda (baad Firebase)
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        // AuthProvider lazem ykoun 9bal ZonesProvider
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
        ChangeNotifierProvider(create: (_) => ReglagesProvider(prefs)),
        ChangeNotifierProvider(
          create: (context) =>
              ZonesProvider(prefs, context.read<AuthProvider>()),
        ),
        ChangeNotifierProvider(create: (_) => MeteoProvider(prefs)..charger()),
        ChangeNotifierProvider(create: (_) => TranslationProvider()), // jdid
      ],
      child: const MyApp(),
    ),
  );
}