class SalesReport {
  final int totalTurnover;
  final int totalTransactions;
  final int totalItemsSold;
  final String? mostSoldProductName;
  final int? mostSoldProductQty;

  SalesReport({
    required this.totalTurnover,
    required this.totalTransactions,
    required this.totalItemsSold,
    this.mostSoldProductName,
    this.mostSoldProductQty,
  });

  factory SalesReport.fromJson(Map<String, dynamic> json) {
    return SalesReport(
      totalTurnover: json['total_turnover'] ?? 0,
      totalTransactions: json['total_transactions'] ?? 0,
      totalItemsSold: json['total_items_sold'] ?? 0,
      mostSoldProductName: json['most_sold_product']?['name'],
      mostSoldProductQty: json['most_sold_product']?['qty'],
    );
  }
}
