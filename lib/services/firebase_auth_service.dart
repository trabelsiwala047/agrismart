import 'package:agrismart/models/utilisateur.dart';
import 'package:agrismart/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';

class FirebaseAuthService implements AuthService {
  final fb.FirebaseAuth _auth;

  FirebaseAuthService({fb.FirebaseAuth? auth})
      : _auth = auth ?? fb.FirebaseAuth.instance;

  Utilisateur? _mapUser(fb.User? user) {
    if (user == null) return null;
    return Utilisateur(
      uid: user.uid,
      email: user.email ?? '',
    );
  }

  @override
  Stream<Utilisateur?> get utilisateur {
    return _auth.authStateChanges().map(_mapUser);
  }

  @override
  Future<void> connexion(String email, String motDePasse) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: motDePasse,
      );
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_traduireErreur(e.code));
    } catch (_) {
      throw const AuthException('Une erreur inattendue est survenue.');
    }
  }

  @override
  Future<void> inscription(String email, String motDePasse) async {
    debugPrint('FIREBASE PROJECT: ${_auth.app.options.projectId}');
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: motDePasse,
      );}
    on fb.FirebaseAuthException catch (e) {
      throw AuthException(_traduireErreur(e.code));
    } catch (_) {
      throw const AuthException('Une erreur inattendue est survenue.');
    }
  }

  @override
  Future<void> reinitialiserMotDePasse(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_traduireErreur(e.code));
    } catch (_) {
      throw const AuthException('Une erreur inattendue est survenue.');
    }
  }

  @override
  Future<void> deconnexion() async {
    await _auth.signOut();
  }

  String _traduireErreur(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Cette adresse e-mail est déjà utilisée.';
      case 'invalid-email':
        return 'Adresse e-mail invalide.';
      case 'weak-password':
        return 'Mot de passe trop faible (minimum 6 caractères).';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect.';
      case 'network-request-failed':
        return 'Problème de connexion internet.';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard.';
      case 'operation-not-allowed':
        return 'Inscription par e-mail désactivée dans Firebase.';
      default:
        return 'Erreur d\'authentification ($code).';
    }
  }
}