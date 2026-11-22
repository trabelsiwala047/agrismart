import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agrismart/data/jeu_de_donnees.dart';
import 'package:agrismart/models/zone.dart';
import 'package:agrismart/providers/auth_provider.dart';

class ZonesProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  final AuthProvider _auth;
  final List<Zone> _zones = [];
  String? _uid; // utilisateur dont on affiche les zones

  ZonesProvider(this._prefs, this._auth) {
    _auth.addListener(_surChangementUtilisateur);
    _actualiser(); // charge les zones de l'utilisateur déjà connecté
  }

  // filtre "à irriguer"
  bool _seulementAIrriguer = false;
  bool get seulementAIrriguer => _seulementAIrriguer;

  // copie en lecture seule : on ne modifie la liste que par les méthodes
  List<Zone> get zones => List.unmodifiable(_zones);

  // zones affichées dans l'onglet Zones
  List<Zone> get zonesAffichees {
    if (!_seulementAIrriguer) return List.unmodifiable(_zones);
    return List.unmodifiable(_zones.where((z) => z.besoinIrrigation));
  }

  int get nombre => _zones.length;

  int get nombreAIrriguer => _zones.where((z) => z.besoinIrrigation).length;

  double get humiditeMoyenne {
    if (_zones.isEmpty) return 0;
    final somme = _zones.fold<double>(0, (s, z) => s + z.humidite);
    return somme / _zones.length;
  }

  // noms des zones (sauf une), pour refuser un doublon dans le formulaire
  List<String> noms({Zone? sauf}) {
    return _zones.where((z) => z != sauf).map((z) => z.nom).toList();
  }

  // ---------- Stockage ----------

  String _cle(String uid) => 'zones_$uid';

  // Lit les zones d'un utilisateur (jeu de données au tout premier lancement)
  List<Zone> _lire(String uid) {
    final texte = _prefs.getString(_cle(uid));
    if (texte == null) return jeuDeDonnees();
    try {
      final liste = jsonDecode(texte) as List<dynamic>;
      return liste
          .map((e) => Zone.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return jeuDeDonnees(); // données abîmées : on repart du jeu initial
    }
  }

  void _sauvegarder() {
    final uid = _uid;
    if (uid == null) return;
    final texte = jsonEncode(_zones.map((z) => z.toJson()).toList());
    _prefs.setString(_cle(uid), texte);
  }

  // Change d'utilisateur : renvoie true si la liste a changé
  bool _actualiser() {
    final uid = _auth.utilisateur?.uid;
    if (uid == _uid) return false;
    _uid = uid;
    _zones.clear();
    if (uid != null) _zones.addAll(_lire(uid));
    return true;
  }

  void _surChangementUtilisateur() {
    if (_actualiser()) notifyListeners();
  }

  @override
  void dispose() {
    _auth.removeListener(_surChangementUtilisateur);
    super.dispose();
  }

  // ---------- Actions ----------

  void basculerFiltre() {
    _seulementAIrriguer = !_seulementAIrriguer;
    notifyListeners();
  }

  void modifierHumidite(Zone zone, double delta) {
    zone.humidite = (zone.humidite + delta).clamp(0, 100).toDouble();
    _sauvegarder();
    notifyListeners();
  }

  void ajouter(Zone zone) {
    _zones.add(zone);
    _sauvegarder();
    notifyListeners();
  }

  void remplacer(Zone ancienne, Zone nouvelle) {
    final index = _zones.indexOf(ancienne);
    if (index == -1) return;
    _zones[index] = nouvelle;
    _sauvegarder();
    notifyListeners();
  }

  void supprimer(Zone zone) {
    _zones.remove(zone);
    _sauvegarder();
    notifyListeners();
  }
}