import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/api_client.dart';
import '../models/price_log.dart';

class PriceLogProvider with ChangeNotifier {
  List<PriceLog> _priceLogs = [];
  bool _isLoading = false;
  String _searchQuery = '';
  DateTime? _selectedDate;
  Map<String, String> _validationErrors = {};

  int _currentPage = 1;
  static const int _pageSize = 10;

  int get currentPage => _currentPage;
  int get totalPages {
    if (_priceLogs.length < _pageSize) return _currentPage;
    return _currentPage + 1;
  }

  List<PriceLog> get priceLogs {
    // Filter to show only the latest record per product (still needed if backend doesn't filter)
    final Map<int, PriceLog> latestPerProduct = {};
    for (var log in _priceLogs) {
      if (log.product != null) {
        final productId = log.product!.id;
        final existing = latestPerProduct[productId];
        if (existing == null || DateTime.parse(log.createdAt).isAfter(DateTime.parse(existing.createdAt))) {
          latestPerProduct[productId] = log;
        }
      }
    }
    
    final result = latestPerProduct.values.toList();
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  void setPage(int page) {
    if (page < 1 || page > totalPages) return;
    _currentPage = page;
    fetchPriceLogs();
  }

  bool get isLoading => _isLoading;
  Map<String, String> get validationErrors => _validationErrors;

  void clearValidationErrors() {
    _validationErrors = {};
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _currentPage = 1; // Reset to first page
    fetchPriceLogs();
  }

  void setSelectedDate(DateTime? date) {
    _selectedDate = date;
    _currentPage = 1; // Reset to first page
    fetchPriceLogs();
  }

  DateTime? get selectedDate => _selectedDate;

  Future<void> fetchPriceLogs({int? productId}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final queryParams = {
        'page': _currentPage.toString(),
        'limit': _pageSize.toString(),
        if (_searchQuery.isNotEmpty) 'name': _searchQuery,
        if (_selectedDate != null) 'date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
        if (productId != null) 'product_id': productId.toString(),
      };
      
      final queryString = Uri(queryParameters: queryParams).query;
      final res = await ApiClient.get('/price_logs?$queryString');
      
      if (res['success'] == true) {
        _priceLogs = (res['data'] as List).map((p) => PriceLog.fromJson(p)).toList();
      }
    } catch (e) {
      debugPrint('Failed to fetch price logs: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updatePrice(int productId, int oldPrice, int newPrice) async {
    _validationErrors = {};
    notifyListeners();
    try {
      final res = await ApiClient.post('/price_logs/$productId', {
        'old_price': oldPrice,
        'new_price': newPrice,
      });
      if (res['success'] == true) {
        await fetchPriceLogs();
        return true;
      } else if (res['error'] is Map) {
        _validationErrors = Map<String, String>.from(res['error']);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to update price: $e');
    }
    return false;
  }
}
