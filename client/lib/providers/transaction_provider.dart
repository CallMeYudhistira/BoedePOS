import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/api_client.dart';
import '../models/transaction_model.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];
  bool _isInitialLoading = true;
  String _searchQuery = '';
  DateTime? _selectedDate;

  List<TransactionModel> get transactions {
    var filtered = _transactions;
    
    if (_selectedDate != null) {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      filtered = filtered.where((t) => t.createdAt.startsWith(dateStr)).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((t) {
        return t.details.any((d) => d.productName.toLowerCase().contains(query));
      }).toList();
    }
    
    return filtered;
  }

  bool get isLoading => _isInitialLoading && _transactions.isEmpty;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
  
  void setSelectedDate(DateTime? date) {
    _selectedDate = date;
    notifyListeners();
  }

  DateTime? get selectedDate => _selectedDate;

  Future<void> fetchTransactions() async {
    try {
      final res = await ApiClient.get('/transactions');
      if (res['success'] == true) {
        _transactions = (res['data'] as List)
            .map((t) => TransactionModel.fromJson(t))
            .toList();
      }
    } catch (e) {
      debugPrint('Failed to fetch transactions: $e');
    }
    _isInitialLoading = false;
    notifyListeners();
  }
}
