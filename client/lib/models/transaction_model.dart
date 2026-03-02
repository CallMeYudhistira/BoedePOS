class TransactionDetail {
  final int? productId;
  final String productName;
  final int qty;
  final int price;
  final int subtotal;

  TransactionDetail({
    this.productId,
    required this.productName,
    required this.qty,
    required this.price,
    required this.subtotal,
  });

  factory TransactionDetail.fromJson(Map<String, dynamic> json) {
    return TransactionDetail(
      productId: json['product_id'],
      productName: json['product_name'],
      qty: json['qty'],
      price: json['price'],
      subtotal: json['subtotal'],
    );
  }
}

class TransactionModel {
  final int id;
  final int pay;
  final int total;
  final int change;
  final String createdAt;
  final List<TransactionDetail> details;

  TransactionModel({
    required this.id,
    required this.pay,
    required this.total,
    required this.change,
    required this.createdAt,
    required this.details,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    var list = json['transaction_details'] as List? ?? [];
    List<TransactionDetail> detailsList =
        list.map((i) => TransactionDetail.fromJson(i)).toList();

    return TransactionModel(
      id: json['id'],
      pay: json['pay'] ?? 0,
      total: json['total'] ?? 0,
      change: json['change'] ?? 0,
      createdAt: json['created_at'],
      details: detailsList,
    );
  }
}
