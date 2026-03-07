import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../core/constants.dart';
import '../../models/product.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  void _showProductDialog({Product? product}) {
    context.read<ProductProvider>().clearValidationErrors();
    final nameController = TextEditingController(text: product?.name ?? '');
    final priceController = TextEditingController(text: product?.price.toString() ?? '');
    bool isFraction = product?.isFraction ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Consumer<ProductProvider>(
              builder: (context, provider, child) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: 24, right: 24, top: 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product == null ? 'Tambah Produk Baru' : 'Edit Produk',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppConstants.textDarkColor),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Nama Produk',
                          errorText: provider.validationErrors['name'],
                          filled: true,
                          fillColor: AppConstants.backgroundColor,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: priceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: false),
                        decoration: InputDecoration(
                          labelText: 'Harga Dasar (Rp)',
                          errorText: provider.validationErrors['price'],
                          filled: true,
                          fillColor: AppConstants.backgroundColor,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: AppConstants.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CheckboxListTile(
                          title: const Text('Barang Pecahan? (Harga Variabel)'),
                          value: isFraction,
                          activeColor: AppConstants.primaryColor,
                          checkColor: AppConstants.textDarkColor,
                          onChanged: (val) {
                            setState(() {
                              isFraction = val ?? false;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            final name = nameController.text;
                            final price = int.tryParse(priceController.text) ?? 0;
                            
                            bool success;
                            if (product == null) {
                              success = await provider.addProduct(name, price, isFraction);
                            } else {
                              success = await provider.updateProduct(product.id, name, price, isFraction);
                            }
                            if (success && context.mounted) Navigator.pop(context);
                          },
                          child: Text(product == null ? 'Simpan Produk' : 'Update Produk', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              }
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppConstants.commonBorderRadius,
                boxShadow: AppConstants.commonShadow,
              ),
              child: TextField(
                onChanged: (val) => context.read<ProductProvider>().setSearchQuery(val),
                decoration: InputDecoration(
                  hintText: 'Cari produk berdasarkan nama atau ID...',

                  hintStyle: const TextStyle(color: AppConstants.textLightColor, fontWeight: FontWeight.w500, fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppConstants.primaryColor, size: 24),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
                  return RefreshIndicator(
                    onRefresh: () => provider.fetchProducts(),
                    child: ListView(
                      children: const [
                        SizedBox(height: 100),
                        Center(child: Text('Produk tidak ditemukan.', style: TextStyle(color: Colors.grey, fontSize: 14))),
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
                        child: ListView.builder(
                          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                          itemCount: provider.products.length,
                          itemBuilder: (context, index) {
                            final p = provider.products[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: AppConstants.commonBorderRadius,
                                boxShadow: AppConstants.commonShadow,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppConstants.backgroundColor,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(
                                        p.isFraction ? Icons.scale_rounded : Icons.inventory_2_rounded,
                                        color: p.isFraction ? Colors.orange : AppConstants.primaryColor,
                                        size: 26,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            p.name, 
                                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppConstants.textDarkColor, height: 1.2),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            AppConstants.currencyFormat.format(p.price),
                                            style: const TextStyle(color: AppConstants.primaryColor, fontWeight: FontWeight.w900, fontSize: 13),
                                          ),
                                          Text(
                                            p.isFraction ? "Berat Variabel" : "Satuan Standar",
                                            style: TextStyle(fontSize: 11, color: p.isFraction ? Colors.orange : AppConstants.textLightColor, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _buildActionBtn(Icons.edit_note_rounded, Colors.blue, () => _showProductDialog(product: p)),
                                        const SizedBox(width: 8),
                                        _buildActionBtn(Icons.delete_sweep_rounded, Colors.red, () async {
                                          bool confirm = await showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                              title: const Text('Hapus Produk', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                                              content: Text('Apakah Anda yakin ingin menghapus ${p.name}?', style: const TextStyle(fontSize: 14)),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                                  onPressed: () => Navigator.pop(context, true), 
                                                  child: const Text('Hapus'),
                                                ),
                                              ],
                                            ),
                                          ) ?? false;
                                          if (confirm && context.mounted) {
                                            context.read<ProductProvider>().deleteProduct(p.id);
                                          }
                                        }),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showProductDialog(),
                          icon: const Icon(Icons.add_business_rounded, size: 20),
                          label: const Text("Buat Produk Baru", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                          ),
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
    );
  }

  Widget _buildPaginationControls(ProductProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
            icon: const Icon(Icons.chevron_left_rounded),
            style: IconButton.styleFrom(backgroundColor: AppConstants.backgroundColor),
          ),
          Text(
            'Halaman ${provider.currentPage} dari ${provider.totalPages}',
            style: const TextStyle(fontWeight: FontWeight.w700, color: AppConstants.textDarkColor, fontSize: 14),
          ),
          IconButton(
            onPressed: provider.currentPage < provider.totalPages ? () => provider.setPage(provider.currentPage + 1) : null,
            icon: const Icon(Icons.chevron_right_rounded),
            style: IconButton.styleFrom(backgroundColor: AppConstants.backgroundColor),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}
