import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isInitialLoading = true;

  List<Product> get products => _products;
  bool get isLoading => _isInitialLoading && _products.isEmpty;

  Future<void> fetchProducts() async {
    try {
      final res = await ApiClient.get('/products');
      if (res['success'] == true) {
        _products = (res['data'] as List).map((p) => Product.fromJson(p)).toList();
      }
    } catch (e) {
      print('Failed to fetch products: $e');
    }
    _isInitialLoading = false;
    notifyListeners();
  }

  Future<bool> addProduct(String name, int price, bool isFraction) async {
    try {
      final res = await ApiClient.post('/products', {
        'name': name,
        'price': price,
        'is_fraction': isFraction,
      });
      if (res['success'] == true) {
        await fetchProducts();
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<bool> updateProduct(int id, String name, int price, bool isFraction) async {
    try {
      final res = await ApiClient.put('/products/$id', {
        'name': name,
        'price': price,
        'is_fraction': isFraction,
      });
      if (res['success'] == true) {
        await fetchProducts();
        return true;
      }
    } catch (e) {
      print(e);
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
      print(e);
    }
    return false;
  }
}
