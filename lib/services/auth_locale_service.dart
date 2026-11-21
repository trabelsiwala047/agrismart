import 'dart:async';
import 'dart:convert';
import 'package:agrismart/models/utilisateur.dart';
import 'package:agrismart/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLocaleService implements AuthService {
  static const String _storageKey = 'agrismart_local_accounts_v1';
  static const String _sessionKey = 'agrismart_local_current_user_v1';

  final Map<String, String> _comptes = {
    'demo@agrismart.tn': '123456',
  };

  final StreamController<Utilisateur?> _controller =
  StreamController<Utilisateur?>.broadcast();

  Utilisateur? _courant;
  bool _charge = false;

  Future<void> _chargerComptes() async {
    if (_charge) return;
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        decoded.forEach((key, value) {
          if (value is String) {
            _comptes[key.trim().toLowerCase()] = value;
          }
        });
      } catch (_) {
        // Ignorer si les données locales sont corrompues
      }
    }

    final savedEmail = prefs.getString(_sessionKey);
    if (savedEmail != null && _comptes.containsKey(savedEmail)) {
      _courant = Utilisateur(uid: savedEmail, email: savedEmail);
    }

    _charge = true;
  }

  Future<void> _sauvegarderComptes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_comptes));
  }

  Future<void> _definir(Utilisateur? u) async {
    _courant = u;
    final prefs = await SharedPreferences.getInstance();
    if (u == null) {
      await prefs.remove(_sessionKey);
    } else {
      await prefs.setString(_sessionKey, u.email);
    }
    if (!_controller.isClosed) {
      _controller.add(u);
    }
  }

  @override
  Stream<Utilisateur?> get utilisateur async* {
    await _chargerComptes();
    yield _courant;
    yield* _controller.stream;
  }

  @override
  Future<void> connexion(String email, String motDePasse) async {
    await _chargerComptes();
    await Future.delayed(const Duration(milliseconds: 500));

    final cle = email.trim().toLowerCase();
    if (cle.isEmpty || motDePasse.isEmpty) {
      throw const AuthException('Veuillez remplir tous les champs');
    }
    if (_comptes[cle] != motDePasse) {
      throw const AuthException('Email ou mot de passe incorrect');
    }

    await _definir(Utilisateur(uid: cle, email: cle));
  }

  @override
  Future<void> inscription(String email, String motDePasse) async {
    await _chargerComptes();
    await Future.delayed(const Duration(milliseconds: 500));

    final cle = email.trim().toLowerCase();
    if (cle.isEmpty || !cle.contains('@')) {
      throw const AuthException('Adresse e-mail invalide');
    }
    if (motDePasse.length < 6) {
      throw const AuthException('Le mot de passe doit contenir au moins 6 caractères');
    }
    if (_comptes.containsKey(cle)) {
      throw const AuthException('Un compte existe déjà avec cet email');
    }

    _comptes[cle] = motDePasse;
    await _sauvegarderComptes();
    await _definir(Utilisateur(uid: cle, email: cle));
  }

  @override
  Future<void> reinitialiserMotDePasse(String email) async {
    await _chargerComptes();
    await Future.delayed(const Duration(milliseconds: 500));

    final cle = email.trim().toLowerCase();
    if (cle.isEmpty || !cle.contains('@')) {
      throw const AuthException('Adresse e-mail invalide');
    }
    if (!_comptes.containsKey(cle)) {
      throw const AuthException('Aucun compte trouvé avec cet email');
    }
  }

  @override
  Future<void> deconnexion() async {
    await _definir(null);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}