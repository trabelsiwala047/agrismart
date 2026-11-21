import 'package:flutter/foundation.dart';
import 'package:agrismart/data/jeu_de_donnees.dart';
import 'package:agrismart/models/zone.dart';

class ZonesProvider extends ChangeNotifier {
  final List<Zone> _zones = jeuDeDonnees();

  //  filtre "à irriguer"
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

  //
  double get humiditeMoyenne {
    if (_zones.isEmpty) return 0;
    final somme = _zones.fold<double>(0, (s, z) => s + z.humidite);
    return somme / _zones.length;
  }

  // noms des zones (sauf une), pour refuser un doublon dans le formulaire
  List<String> noms({Zone? sauf}) {
    return _zones.where((z) => z != sauf).map((z) => z.nom).toList();
  }

  void basculerFiltre() {
    _seulementAIrriguer = !_seulementAIrriguer;
    notifyListeners();
  }

  void modifierHumidite(Zone zone, double delta) {
    zone.humidite = (zone.humidite + delta).clamp(0, 100).toDouble();
    notifyListeners();
  }

  void ajouter(Zone zone) {
    _zones.add(zone);
    notifyListeners();
  }

  void remplacer(Zone ancienne, Zone nouvelle) {
    final index = _zones.indexOf(ancienne);
    if (index == -1) return;
    _zones[index] = nouvelle;
    notifyListeners();
  }

  void supprimer(Zone zone) {
    _zones.remove(zone);
    notifyListeners();
  }
}