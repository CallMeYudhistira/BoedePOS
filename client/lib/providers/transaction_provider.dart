import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/transaction_model.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];
  bool _isInitialLoading = true;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isInitialLoading && _transactions.isEmpty;

  Future<void> fetchTransactions() async {
    try {
      final res = await ApiClient.get('/transactions');
      if (res['success'] == true) {
        _transactions = (res['data'] as List)
            .map((t) => TransactionModel.fromJson(t))
            .toList();
      }
    } catch (e) {
      print('Failed to fetch transactions: $e');
    }
    _isInitialLoading = false;
    notifyListeners();
  }
}
