import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  bool _isCheckingOut = false;

  List<CartItem> get items => _items;
  bool get isCheckingOut => _isCheckingOut;

  int get totalAmount {
    return _items.fold(0, (sum, item) => sum + (item.price * item.qty));
  }

  void addToCart(Product product, {int? customPrice}) {
    int index = _items.indexWhere((item) => item.productId == product.id && item.price == (customPrice ?? product.price));
    if (index >= 0) {
      _items[index].qty++;
    } else {
      _items.add(CartItem(
        productId: product.id,
        name: product.name,
        price: customPrice ?? product.price,
        qty: 1,
        isFraction: product.isFraction,
      ));
    }
    notifyListeners();
  }

  void updateQty(CartItem item, int newQty) {
    if (newQty <= 0) {
      _items.remove(item);
    } else {
      item.qty = newQty;
    }
    notifyListeners();
  }

  void updatePrice(CartItem item, int newPrice) {
    item.price = newPrice;
    notifyListeners();
  }

  void removeItem(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  Future<bool> checkout(int paymentAmount) async {
    if (_items.isEmpty) return false;
    _isCheckingOut = true;
    notifyListeners();

    try {
      final payload = {
        'pay': paymentAmount,
        'items': _items.map((item) => {
          'product_id': item.productId,
          'product_name': item.name,
          'qty': item.qty,
          'price': item.price,
        }).toList()
      };

      final res = await ApiClient.post('/transactions', payload);
      if (res['success']) {
        clearCart();
        _isCheckingOut = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print(e);
    }

    _isCheckingOut = false;
    notifyListeners();
    return false;
  }
}
