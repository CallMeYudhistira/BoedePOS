import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../core/constants.dart';

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.scale_rounded, color: Colors.orange, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            'Harga Variabel untuk ${widget.product.name}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppConstants.textDarkColor, letterSpacing: -0.5),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Masukkan total harga untuk item ini berdasarkan berat atau jumlahnya.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppConstants.textLightColor, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: AppConstants.backgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppConstants.primaryColor),
              decoration: const InputDecoration(
                hintText: 'Masukkan Harga (Rp)',
                hintStyle: TextStyle(fontSize: 16, color: AppConstants.textLightColor, fontWeight: FontWeight.w600),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w700, color: AppConstants.textLightColor)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: () {
                  int customPrice = int.tryParse(_priceController.text) ?? widget.product.price;
                  context.read<CartProvider>().addToCart(widget.product, customPrice: customPrice);
                  Fluttertoast.showToast(
                    msg: "${widget.product.name} ditambahkan ke keranjang",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.black87,
                    textColor: Colors.white,
                  );
                  Navigator.pop(context);
                },
                child: const Text('Tambah Produk', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ],
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
    );
  }
}
