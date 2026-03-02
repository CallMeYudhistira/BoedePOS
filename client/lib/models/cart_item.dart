class CartItem {
  final int productId;
  final String name;
  int price;
  int qty;
  final bool isFraction;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.qty,
    required this.isFraction,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': name,
      'price': price,
      'qty': qty,
    };
  }
}
