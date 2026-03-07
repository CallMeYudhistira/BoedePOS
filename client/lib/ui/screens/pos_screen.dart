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
                  borderRadius: AppConstants.commonBorderRadius,
                  boxShadow: AppConstants.commonShadow,
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    context.read<ProductProvider>().setSearchQuery(value);
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari menu atau produk...',
                    hintStyle: const TextStyle(color: AppConstants.textLightColor, fontWeight: FontWeight.w500),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppConstants.primaryColor, size: 28),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.cancel_rounded, color: Colors.grey, size: 24),
                            onPressed: () {
                              _searchController.clear();
                              context.read<ProductProvider>().setSearchQuery('');
                              setState(() {});
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
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
                          Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty 
                                ? "Produk tidak tersedia." 
                                : "Produk \"${_searchController.text}\" tidak ditemukan.",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }
                  return Column(
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () => provider.fetchProducts(),
                          color: AppConstants.textDarkColor,
                          backgroundColor: AppConstants.primaryColor,
                          child: GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.95,
                            ),
                            itemCount: provider.products.length,
                            itemBuilder: (context, index) {
                              final product = provider.products[index];
                              return GestureDetector(
                                onTap: () => _onProductTap(product),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: AppConstants.commonBorderRadius,
                                    boxShadow: AppConstants.commonShadow,
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppConstants.backgroundColor,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Icon(
                                          product.isFraction ? Icons.scale_rounded : Icons.fastfood_rounded,
                                          color: product.isFraction ? Colors.orange : AppConstants.primaryColor,
                                          size: 32,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Expanded(
                                        child: Text(
                                          product.name,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800, 
                                            fontSize: 18, 
                                            color: AppConstants.textDarkColor,
                                            height: 2.5,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        AppConstants.currencyFormat.format(product.price),
                                        style: const TextStyle(
                                          color: AppConstants.primaryColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      _buildPaginationControls(provider),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationControls(ProductProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: provider.currentPage > 1 ? () => provider.setPage(provider.currentPage - 1) : null,
            icon: const Icon(Icons.chevron_left_rounded, size: 20),
            style: IconButton.styleFrom(backgroundColor: AppConstants.backgroundColor),
          ),
          Text(
            'Halaman ${provider.currentPage} dari ${provider.totalPages}',
            style: const TextStyle(fontWeight: FontWeight.w700, color: AppConstants.textDarkColor, fontSize: 13),
          ),
          IconButton(
            onPressed: provider.currentPage < provider.totalPages ? () => provider.setPage(provider.currentPage + 1) : null,
            icon: const Icon(Icons.chevron_right_rounded, size: 20),
            style: IconButton.styleFrom(backgroundColor: AppConstants.backgroundColor),
          ),
        ],
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: FractionallySizedBox(
          heightFactor: 0.9,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Tinjau Pesanan Anda', 
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppConstants.primaryColor, letterSpacing: -0.5),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Consumer<CartProvider>(
                  builder: (context, cartProvider, child) {
                    if (cartProvider.items.isEmpty) {
                      return const Center(child: Text('Keranjang Anda kosong.'));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: cartProvider.items.length,
                      itemBuilder: (context, index) {
                        final item = cartProvider.items[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: AppConstants.commonBorderRadius,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppConstants.backgroundColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.fastfood_rounded, color: AppConstants.primaryColor, size: 28),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name, 
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppConstants.textDarkColor),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        AppConstants.currencyFormat.format(item.price),
                                        style: const TextStyle(color: AppConstants.textLightColor, fontWeight: FontWeight.w600, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    _buildQtyBtn(Icons.remove_rounded, () => cartProvider.updateQty(item, item.qty - 1)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Text(
                                        '${item.qty}', 
                                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppConstants.textDarkColor),
                                      ),
                                    ),
                                    _buildQtyBtn(Icons.add_rounded, () => cartProvider.updateQty(item, item.qty + 1), isAdd: true),
                                  ],
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
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5)),
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
                            const Text('Total Pembayaran', style: TextStyle(fontSize: 16, color: AppConstants.textLightColor, fontWeight: FontWeight.w600)),
                            Text(
                              AppConstants.currencyFormat.format(cartProvider.totalAmount), 
                              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppConstants.primaryColor, letterSpacing: -0.5),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          decoration: BoxDecoration(
                            color: AppConstants.backgroundColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextField(
                            controller: _paymentController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: false),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppConstants.textDarkColor),
                            onChanged: (val) {
                              if (_paymentError != null) {
                                setState(() => _paymentError = null);
                              }
                            },
                            decoration: InputDecoration(
                              labelText: 'Pembayaran Pelanggan (Rp)',
                              labelStyle: const TextStyle(color: AppConstants.textLightColor, fontWeight: FontWeight.w600),
                              errorText: _paymentError,
                              border: InputBorder.none,
                              prefixIcon: const Icon(Icons.account_balance_wallet_rounded, color: AppConstants.primaryColor, size: 28),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              elevation: 4,
                              shadowColor: AppConstants.primaryColor.withValues(alpha: 0.4),
                            ),
                            onPressed: cartProvider.isCheckingOut || cartProvider.items.isEmpty
                                ? null
                                : () async {
                                    final payAmount = int.tryParse(_paymentController.text) ?? 0;
                                    if (payAmount == 0) {
                                      setState(() => _paymentError = 'Harap masukkan nominal pembayaran');
                                      return;
                                    }
                                    if (payAmount < cartProvider.totalAmount) {
                                      setState(() => _paymentError = 'Pembayaran kurang!');
                                      return;
                                    }
                                    bool success = await cartProvider.checkout(payAmount);
                                    if (success) {
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        _showSuccessDialog(context);
                                      }
                                    } else {
                                      if (context.mounted) {
                                        _showErrorDialog(context);
                                      }
                                    }
                                  },
                            child: cartProvider.isCheckingOut 
                              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) 
                              : const Text('Selesaikan Pembelian', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
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

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap, {bool isAdd = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isAdd ? AppConstants.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isAdd ? AppConstants.primaryColor : Colors.grey.shade300),
        ),
        child: Icon(icon, color: isAdd ? Colors.white : AppConstants.textDarkColor, size: 20),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 80),
            const SizedBox(height: 24),
            const Text('Berhasil!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text('Pembayaran telah selesai diproses.', style: TextStyle(color: AppConstants.textLightColor, fontWeight: FontWeight.w500)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Selesai', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Icon(Icons.error_rounded, color: Colors.red, size: 80),
            const SizedBox(height: 24),
            const Text('Gagal!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text('Terjadi kesalahan. Silakan coba lagi.', style: TextStyle(color: AppConstants.textLightColor, fontWeight: FontWeight.w500)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Coba Lagi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
