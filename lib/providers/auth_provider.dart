
import 'dart:async';
import 'package:flutter/material.dart';

import '../models/utilisateur.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  Utilisateur? _utilisateur;
  bool _initialise = false;
  bool _chargement = false;
  String? _erreur;

  StreamSubscription<Utilisateur?>? _subscription;

  AuthProvider(this._authService) {
    _subscription = _authService.utilisateur.listen((user) {
      _utilisateur = user;
      _initialise = true;
      notifyListeners();
    });
  }

  Utilisateur? get utilisateur => _utilisateur;
  bool get initialise => _initialise;
  bool get chargement => _chargement;
  String? get erreur => _erreur;

  Future<void> connexion(String email, String motDePasse) async {
    await _executer(() => _authService.connexion(email, motDePasse));
  }

  Future<void> inscription(String email, String motDePasse) async {
    await _executer(() => _authService.inscription(email, motDePasse));
  }

  Future<void> reinitialiserMotDePasse(String email) async {
    await _executer(
          () => _authService.reinitialiserMotDePasse(email),
    );
  }

  Future<void> deconnexion() async {
    await _executer(_authService.deconnexion);
  }

  Future<void> _executer(Future<void> Function() action) async {
    _chargement = true;
    _erreur = null;
    notifyListeners();

    try {
      await action();
    } on AuthException catch (e) {
      _erreur = e.message;
    } catch (_) {
      _erreur = 'Une erreur inattendue est survenue.';
    } finally {
      _chargement = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
