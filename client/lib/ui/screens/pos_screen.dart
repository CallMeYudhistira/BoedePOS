import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../core/constants.dart';
import '../../models/product.dart';
import '../widgets/fraction_modal.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductProvider>();
      provider.setSearchQuery('');
      provider.fetchProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onProductTap(Product product) {
    if (product.isFraction) {
      showDialog(
        context: context,
        builder: (context) => FractionModal(product: product),
      );
    } else {
      context.read<CartProvider>().addToCart(product);
      Fluttertoast.showToast(
        msg: "${product.name} ditambahkan ke keranjang",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
      );
    }
  }

  void _showCartSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CartSheetContent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    context.read<ProductProvider>().setSearchQuery(value);
                    setState(() {}); // Rebuild to show/hide clear icon
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari produk...',
                    prefixIcon: const Icon(Icons.search, color: AppConstants.textLightColor),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppConstants.textLightColor),
                            onPressed: () {
                              _searchController.clear();
                              context.read<ProductProvider>().setSearchQuery('');
                              setState(() {});
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.transparent, // Fill is handled by Container
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Consumer<ProductProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor));
                  }
                  if (provider.products.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty 
                                ? "Produk tidak tersedia." 
                                : "Produk \"${_searchController.text}\" tidak ditemukan.",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () => provider.fetchProducts(),
                    color: AppConstants.textDarkColor,
                    backgroundColor: AppConstants.primaryColor,
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Optimized for mobile portrait
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: provider.products.length,
                      itemBuilder: (context, index) {
                        final product = provider.products[index];
                        return GestureDetector(
                          onTap: () => _onProductTap(product),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppConstants.backgroundColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    product.isFraction ? Icons.scale : Icons.shopping_bag,
                                    color: product.isFraction ? Colors.orange : AppConstants.primaryColor,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  product.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppConstants.textDarkColor),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppConstants.currencyFormat.format(product.price),
                                  style: const TextStyle(
                                    color: AppConstants.textLightColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (product.isFraction) 
                                  const Text(
                                    'Barang Pecahan',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomCartBar(context),
    );
  }

  Widget _buildBottomCartBar(BuildContext context) {
    final cart = context.watch<CartProvider>();
    if (cart.items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${cart.items.fold(0, (sum, i) => sum + i.qty)} Barang', 
                  style: const TextStyle(color: AppConstants.textLightColor, fontWeight: FontWeight.w600),
                ),
                Text(
                  AppConstants.currencyFormat.format(cart.totalAmount), 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppConstants.textDarkColor),
                ),
              ],
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => _showCartSheet(context),
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Lihat Keranjang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }
}

class CartSheetContent extends StatefulWidget {
  const CartSheetContent({super.key});

  @override
  State<CartSheetContent> createState() => _CartSheetContentState();
}

class _CartSheetContentState extends State<CartSheetContent> {
  final _paymentController = TextEditingController();
  String? _paymentError;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: AppConstants.backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: FractionallySizedBox(
          heightFactor: 0.85,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                width: double.infinity,
                padding: const EdgeInsets.only(bottom: 16),
                child: const Text(
                  'Keranjang Anda', 
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppConstants.textDarkColor),
                ),
              ),
              Expanded(
                child: Consumer<CartProvider>(
                  builder: (context, cartProvider, child) {
                    if (cartProvider.items.isEmpty) {
                      return const Center(child: Text('Keranjang kosong.'));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: cartProvider.items.length,
                      itemBuilder: (context, index) {
                        final item = cartProvider.items[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              AppConstants.currencyFormat.format(item.price),
                              style: const TextStyle(color: AppConstants.textLightColor),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: AppConstants.textDarkColor),
                                  onPressed: () => cartProvider.updateQty(item, item.qty - 1),
                                ),
                                Text('${item.qty}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, color: AppConstants.textDarkColor),
                                  onPressed: () => cartProvider.updateQty(item, item.qty + 1),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
                  ],
                ),
                child: Consumer<CartProvider>(
                  builder: (context, cartProvider, child) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Harga', style: TextStyle(fontSize: 16, color: AppConstants.textLightColor)),
                            Text(
                              AppConstants.currencyFormat.format(cartProvider.totalAmount), 
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppConstants.textDarkColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _paymentController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: false),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          onChanged: (val) {
                            if (_paymentError != null) {
                              setState(() => _paymentError = null);
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Pembayaran Pelanggan (Rp)',
                            labelStyle: const TextStyle(color: AppConstants.textLightColor),
                            errorText: _paymentError,
                            filled: true,
                            fillColor: AppConstants.backgroundColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.payments, color: AppConstants.textDarkColor),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.textDarkColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: cartProvider.isCheckingOut || cartProvider.items.isEmpty
                                ? null
                                : () async {
                                    final payAmount = int.tryParse(_paymentController.text) ?? 0;
                                    if (payAmount == 0) {
                                      setState(() => _paymentError = 'Harap masukkan jumlah pembayaran');
                                      return;
                                    }
                                    if (payAmount < cartProvider.totalAmount) {
                                      setState(() => _paymentError = 'Pembayaran tidak cukup!');
                                      return;
                                    }
                                    bool success = await cartProvider.checkout(payAmount);
                                    if (success) {
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checkout Berhasil!')));
                                      }
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checkout Gagal!')));
                                      }
                                    }
                                  },
                            child: cartProvider.isCheckingOut 
                              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                              : const Text('Proses Checkout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    );
                  }
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
