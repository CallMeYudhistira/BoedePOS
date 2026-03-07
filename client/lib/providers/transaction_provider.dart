import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/api_client.dart';
import '../models/transaction_model.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];
  bool _isInitialLoading = true;
  String _searchQuery = '';
  DateTime? _selectedDate;

  int _currentPage = 1;
  static const int _pageSize = 10;

  int get currentPage => _currentPage;
  int get totalPages {
    if (_transactions.length < _pageSize) return _currentPage;
    return _currentPage + 1;
  }

  List<TransactionModel> get transactions {
    return _transactions;
  }

  void setPage(int page) {
    if (page < 1 || page > totalPages) return;
    _currentPage = page;
    fetchTransactions();
  }

  bool get isLoading => _isInitialLoading;

  void setSearchQuery(String query) {
    _searchQuery = query;
    _currentPage = 1; // Reset to first page
    fetchTransactions();
  }
  
  void setSelectedDate(DateTime? date) {
    _selectedDate = date;
    _currentPage = 1; // Reset to first page
    fetchTransactions();
  }

  DateTime? get selectedDate => _selectedDate;

  Future<void> fetchTransactions() async {
    _isInitialLoading = true;
    notifyListeners();
    try {
      final queryParams = {
        'page': _currentPage.toString(),
        'limit': _pageSize.toString(),
        if (_selectedDate != null) 'date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
      };
      
      final queryString = Uri(queryParameters: queryParams).query;
      final res = await ApiClient.get('/transactions?$queryString');
      
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
