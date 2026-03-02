import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isInitialLoading = true;
  String _searchQuery = '';
  Map<String, String> _validationErrors = {};

  List<Product> get products {
    if (_searchQuery.isEmpty) return _products;
    return _products.where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }
  
  bool get isLoading => _isInitialLoading && _products.isEmpty;
  Map<String, String> get validationErrors => _validationErrors;

  void clearValidationErrors() {
    _validationErrors = {};
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchProducts() async {
    try {
      final res = await ApiClient.get('/products');
      if (res['success'] == true) {
        _products = (res['data'] as List).map((p) => Product.fromJson(p)).toList();
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
