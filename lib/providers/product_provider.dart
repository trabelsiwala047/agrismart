import 'package:flutter/foundation.dart';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  // Catalogue de démo (baad nbadlouh b API wala Firebase)
  final Map<String, Product> _catalogue = {
    'ENG001': Product(
        code: 'ENG001',
        name: 'Engrais NPK 20-20-20',
        category: 'Engrais',
        description: 'Engrais équilibré pour toutes les cultures.'),
    'SEM001': Product(
        code: 'SEM001',
        name: 'Semences de tomate',
        category: 'Semences',
        description: 'Variété résistante à la chaleur.'),
    'PES001': Product(
        code: 'PES001',
        name: 'Fongicide cuivre',
        category: 'Pesticide',
        description: 'Contre le mildiou. Respecter le dosage.'),
  };

  final Map<String, Product> _stock = {};

  List<Product> get stock => _stock.values.toList();

  Product? findByCode(String code) => _catalogue[code];

  void addToStock(Product p) {
    if (_stock.containsKey(p.code)) {
      _stock[p.code]!.quantity++;
    } else {
      _stock[p.code] = Product(
        code: p.code,
        name: p.name,
        category: p.category,
        description: p.description,
        quantity: 1,
      );
    }
    notifyListeners();
  }

  void remove(String code) {
    _stock.remove(code);
    notifyListeners();
  }
}