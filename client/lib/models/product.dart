class Product {
  final int id;
  final String name;
  final int price;
  final bool isFraction;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.isFraction,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      isFraction: json['is_fraction'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'is_fraction': isFraction,
    };
  }
}
