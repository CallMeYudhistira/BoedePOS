import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isInitialLoading = true;
  String _searchQuery = '';
  Map<String, String> _validationErrors = {};

  int _currentPage = 1;
  static const int _pageSize = 10;

  int get currentPage => _currentPage;
  int get totalPages {
    // Basic estimation since API doesn't return total count
    if (_products.length < _pageSize) return _currentPage;
    return _currentPage + 1;
  }

  List<Product> get products {
    return _products;
  }

  void setPage(int page) {
    if (page < 1 || page > totalPages) return;
    _currentPage = page;
    fetchProducts(); // Re-fetch on page change
  }
  
  bool get isLoading => _isInitialLoading; // Adjusted isLoading
  Map<String, String> get validationErrors => _validationErrors;

  void clearValidationErrors() {
    _validationErrors = {};
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _currentPage = 1; // Reset to first page on search
    fetchProducts(); // Re-fetch on search
  }

  Future<void> fetchProducts() async {
    _isInitialLoading = true;
    notifyListeners();
    try {
      final queryParams = {
        'page': _currentPage.toString(),
        'limit': _pageSize.toString(),
        if (_searchQuery.isNotEmpty) 'name': _searchQuery,
      };
      
      final queryString = Uri(queryParameters: queryParams).query;
      final res = await ApiClient.get('/products?$queryString');
      
      if (res['success'] == true) {
        _products = (res['data'] as List).map((p) => Product.fromJson(p)).toList();
        // Note: Total pages might need a separate count from API for accurate pagination
        // Since API doesn't return total count yet, we'll keep a simple approach
      }
    } catch (e) {
      debugPrint('Failed to fetch products: $e');
    }
    _isInitialLoading = false;
    notifyListeners();
  }

  Future<bool> addProduct(String name, int price, bool isFraction) async {
    _validationErrors = {};
    notifyListeners();
    try {
      final res = await ApiClient.post('/products', {
        'name': name,
        'price': price,
        'is_fraction': isFraction,
      });
      if (res['success'] == true) {
        await fetchProducts();
        return true;
      } else if (res['error'] is Map) {
        _validationErrors = Map<String, String>.from(res['error']);
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return false;
  }

  Future<bool> updateProduct(int id, String name, int price, bool isFraction) async {
    _validationErrors = {};
    notifyListeners();
    try {
      final res = await ApiClient.put('/products/$id', {
        'name': name,
        'price': price,
        'is_fraction': isFraction,
      });
      if (res['success'] == true) {
        await fetchProducts();
        return true;
      } else if (res['error'] is Map) {
        _validationErrors = Map<String, String>.from(res['error']);
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return false;
  }

  Future<bool> deleteProduct(int id) async {
    try {
      final res = await ApiClient.delete('/products/$id');
      if (res['success'] == true) {
        await fetchProducts();
        return true;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return false;
  }
}
