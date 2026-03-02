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

  List<PriceLog> get priceLogs {
    var filtered = _priceLogs;
    
    if (_selectedDate != null) {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      filtered = filtered.where((l) => l.createdAt.startsWith(dateStr)).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((l) => (l.product?.name.toLowerCase() ?? '').contains(query)).toList();
    }
    
    return filtered;
  }

  bool get isLoading => _isLoading && _priceLogs.isEmpty;
  Map<String, String> get validationErrors => _validationErrors;

  void clearValidationErrors() {
    _validationErrors = {};
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedDate(DateTime? date) {
    _selectedDate = date;
    notifyListeners();
  }

  DateTime? get selectedDate => _selectedDate;

  Future<void> fetchPriceLogs({int? productId}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final endpoint = productId != null ? '/price_logs/$productId' : '/price_logs';
      final res = await ApiClient.get(endpoint);
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
