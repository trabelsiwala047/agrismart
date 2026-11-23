class Product {
  final String code;
  final String name;
  final String category;
  final String description;
  int quantity;

  Product({
    required this.code,
    required this.name,
    required this.category,
    required this.description,
    this.quantity = 0,
  });
}