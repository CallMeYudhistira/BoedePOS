import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';

class FractionModal extends StatefulWidget {
  final Product product;

  const FractionModal({super.key, required this.product});

  @override
  State<FractionModal> createState() => _FractionModalState();
}

class _FractionModalState extends State<FractionModal> {
  final _priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Pilih Harga untuk ${widget.product.name}'),
      content: TextField(
        controller: _priceController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Harga Kustom',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            int customPrice = int.tryParse(_priceController.text) ?? widget.product.price;
            context.read<CartProvider>().addToCart(widget.product, customPrice: customPrice);
            Navigator.pop(context);
          },
          child: const Text('Tambah ke Keranjang'),
        ),
      ],
    );
  }
}
