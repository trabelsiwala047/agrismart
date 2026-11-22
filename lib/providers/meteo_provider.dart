import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agrismart/models/meteo.dart';
import 'package:agrismart/services/meteo_service.dart';

// Les trois etats d'un chargement reseau
enum EtatMeteo { chargement, succes, erreur }

class MeteoProvider extends ChangeNotifier {
  static const _cleMeteo = 'meteo_json';
  static const _cleDate = 'meteo_date';

  final SharedPreferences _prefs;
  final MeteoService _service;

  MeteoProvider(this._prefs, {MeteoService? service})
      : _service = service ?? MeteoService();

  EtatMeteo _etat = EtatMeteo.chargement;
  Meteo? _meteo;
  String _erreur = '';
  bool _horsLigne = false; // vrai : donnees enregistrees
  DateTime? _miseAJour; // moment ou ces donnees ont ete recues

  EtatMeteo get etat => _etat;
  Meteo? get meteo => _meteo;
  String get erreur => _erreur;
  bool get horsLigne => _horsLigne;
  DateTime? get miseAJour => _miseAJour;

  Future<void> charger() async {
    _etat = EtatMeteo.chargement;
    notifyListeners();

    try {
      _meteo = await _service.charger();
      _etat = EtatMeteo.succes;
      _horsLigne = false;
      _miseAJour = DateTime.now();
      await _enregistrer(_meteo!, _miseAJour!);
    } on MeteoException catch (e) {
      _echec(e.message);
    } catch (_) {
      _echec('Erreur inattendue');
    }
    notifyListeners(); // dans tous les cas, on previent l'ecran
  }

  // En cas d'echec : on tente d'afficher la derniere meteo enregistree
  void _echec(String message) {
    final enCache = _lireCache();
    if (enCache != null) {
      _meteo = enCache;
      _etat = EtatMeteo.succes;
      _horsLigne = true;
      return;
    }
    _erreur = message;
    _etat = EtatMeteo.erreur;
  }

  Future<void> _enregistrer(Meteo meteo, DateTime date) async {
    await _prefs.setString(_cleMeteo, jsonEncode(meteo.toJson()));
    await _prefs.setString(_cleDate, date.toIso8601String());
  }

  Meteo? _lireCache() {
    final texte = _prefs.getString(_cleMeteo);
    if (texte == null) return null;
    try {
      _miseAJour = DateTime.tryParse(_prefs.getString(_cleDate) ?? '');
      return Meteo.fromJson(jsonDecode(texte) as Map<String, dynamic>);
    } catch (_) {
      return null; // cache illisible : comme s'il n'y avait rien
    }
  }
}