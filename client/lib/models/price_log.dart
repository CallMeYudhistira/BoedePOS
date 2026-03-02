import 'product.dart';

class PriceLog {
  final int id;
  final int productId;
  final int oldPrice;
  final int newPrice;
  final String createdAt;
  final Product? product;

  PriceLog({
    required this.id,
    required this.productId,
    required this.oldPrice,
    required this.newPrice,
    required this.createdAt,
    this.product,
  });

  factory PriceLog.fromJson(Map<String, dynamic> json) {
    return PriceLog(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      oldPrice: json['old_price'] ?? 0,
      newPrice: json['new_price'] ?? 0,
      createdAt: json['created_at'] ?? '',
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
    );
  }
}
