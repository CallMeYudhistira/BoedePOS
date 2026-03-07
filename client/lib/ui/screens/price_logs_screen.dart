import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/price_log_provider.dart';
import '../../providers/product_provider.dart';
import '../../core/constants.dart';
import '../../core/navigation_service.dart';
import '../../models/product.dart';

class PriceLogsScreen extends StatefulWidget {
  const PriceLogsScreen({super.key});

  @override
  State<PriceLogsScreen> createState() => _PriceLogsScreenState();
}

class _PriceLogsScreenState extends State<PriceLogsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PriceLogProvider>().fetchPriceLogs();
      context.read<ProductProvider>().fetchProducts();
    });
  }

  void _showAddPriceLogSheet({Product? initialProduct}) {
    context.read<PriceLogProvider>().clearValidationErrors();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => AddPriceLogSheet(initialProduct: initialProduct),
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
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppConstants.commonBorderRadius,
                      boxShadow: AppConstants.commonShadow,
                    ),
                    child: TextField(
                      onChanged: (val) => context.read<PriceLogProvider>().setSearchQuery(val),
                      decoration: InputDecoration(
                        hintText: 'Cari riwayat produk...',
                        hintStyle: const TextStyle(color: AppConstants.textLightColor, fontWeight: FontWeight.w500),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppConstants.primaryColor, size: 28),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Consumer<PriceLogProvider>(
                  builder: (context, provider, child) {
                    final isDateSelected = provider.selectedDate != null;
                    return InkWell(
                      onTap: () async {
                        if (isDateSelected) {
                          provider.setSelectedDate(null);
                        } else {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: AppConstants.primaryColor,
                                    onPrimary: Colors.white,
                                    onSurface: AppConstants.textDarkColor,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (date != null) provider.setSelectedDate(date);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDateSelected ? AppConstants.primaryColor : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppConstants.commonShadow,
                        ),
                        child: Icon(
                          isDateSelected ? Icons.event_busy_rounded : Icons.calendar_month_rounded,
                          color: isDateSelected ? Colors.white : AppConstants.primaryColor,
                          size: 28,
                        ),
                      ),
                    );
                  }
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<PriceLogProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor));
                }
                if (provider.priceLogs.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => provider.fetchPriceLogs(),
                    child: ListView(
                      children: const [
                        SizedBox(height: 100),
                        Center(child: Text('Tidak ada riwayat harga.', style: TextStyle(color: Colors.grey, fontSize: 14))),
                      ],
                    ),
                  );
                }
                return Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => provider.fetchPriceLogs(),
                        color: AppConstants.textDarkColor,
                        backgroundColor: AppConstants.primaryColor,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                          itemCount: provider.priceLogs.length,
                          itemBuilder: (context, index) {
                            final log = provider.priceLogs[index];
                            final isUp = log.newPrice > log.oldPrice;
                            final isDown = log.newPrice < log.oldPrice;
                            final date = DateTime.tryParse(log.createdAt) ?? DateTime.now();

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: AppConstants.commonBorderRadius,
                                boxShadow: AppConstants.commonShadow,
                              ),
                              child: InkWell(
                                onTap: log.product != null ? () => _showAddPriceLogSheet(initialProduct: log.product) : null,
                                borderRadius: AppConstants.commonBorderRadius,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isUp ? Colors.red.withValues(alpha: 0.1) : isDown ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Icon(
                                          isUp ? Icons.trending_up_rounded : isDown ? Icons.trending_down_rounded : Icons.trending_flat_rounded,
                                          color: isUp ? Colors.red : isDown ? Colors.green : Colors.grey,
                                          size: 26,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              log.product?.name ?? 'Unknown Product',
                                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppConstants.textDarkColor, height: 1.2),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Text(
                                                  AppConstants.currencyFormat.format(log.oldPrice),
                                                  style: const TextStyle(
                                                    color: AppConstants.textLightColor,
                                                    decoration: TextDecoration.lineThrough,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                const Icon(Icons.arrow_forward_rounded, size: 12, color: AppConstants.textLightColor),
                                                const SizedBox(width: 6),
                                                Text(
                                                  AppConstants.currencyFormat.format(log.newPrice),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 14,
                                                    color: isUp ? Colors.red : isDown ? Colors.green : Colors.grey,
                                                    letterSpacing: -0.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              DateFormat('dd MMM yyyy • HH:mm').format(date),
                                              style: const TextStyle(color: AppConstants.textLightColor, fontSize: 11, fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
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
    );
  }

  Widget _buildPaginationControls(PriceLogProvider provider) {
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
}

class AddPriceLogSheet extends StatefulWidget {
  final Product? initialProduct;
  const AddPriceLogSheet({super.key, this.initialProduct});

  @override
  State<AddPriceLogSheet> createState() => _AddPriceLogSheetState();
}

class _AddPriceLogSheetState extends State<AddPriceLogSheet> {
  Product? _selectedProduct;
  final _newPriceController = TextEditingController();
  final _autocompleteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialProduct != null) {
      _selectedProduct = widget.initialProduct;
      _autocompleteController.text = _selectedProduct!.name;
      _newPriceController.text = _selectedProduct!.price.toString();
    }
  }

  @override
  void dispose() {
    _newPriceController.dispose();
    _autocompleteController.dispose();
    super.dispose();
  }

  void _adjustPrice(int amount) {
    final current = int.tryParse(_newPriceController.text) ?? 0;
    final newValue = (current + amount).clamp(0, 999999999);
    _newPriceController.text = newValue.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProductProvider, PriceLogProvider>(
      builder: (context, productProvider, priceLogProvider, child) {
        final products = productProvider.products;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24, right: 24, top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Perbarui Harga Produk',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.textDarkColor),
              ),
              const SizedBox(height: 20),
              
              const Text('Pilih Produk', style: TextStyle(fontWeight: FontWeight.w600, color: AppConstants.textLightColor, fontSize: 13)),
              const SizedBox(height: 8),
              
              Autocomplete<Product>(
                displayStringForOption: (Product p) => p.name,
                initialValue: TextEditingValue(text: _selectedProduct?.name ?? ''),
                optionsBuilder: (TextEditingValue textEditingValue) {
                  // Always return all products since typing is disabled
                  return products;
                },
                onSelected: (Product p) {
                  setState(() {
                    _selectedProduct = p;
                    _newPriceController.text = p.price.toString();
                  });
                },
                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                  if (controller.text.isEmpty && _selectedProduct != null) {
                    controller.text = _selectedProduct!.name;
                  }
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    readOnly: true, // Disable typing
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    onTap: () {
                      // Trigger options by clearing then restoring or just clicking
                    },
                    decoration: InputDecoration(
                      hintText: 'Ketuk untuk memilih produk...',
                      hintStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                      filled: true,
                      fillColor: AppConstants.backgroundColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      suffixIcon: const Icon(Icons.arrow_drop_down_circle_rounded, color: AppConstants.primaryColor, size: 20),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      borderRadius: BorderRadius.circular(12),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 200, maxWidth: MediaQuery.of(context).size.width - 48),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final Product option = options.elementAt(index);
                            return ListTile(
                              title: Text(option.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                              subtitle: Text(AppConstants.currencyFormat.format(option.price), style: const TextStyle(fontSize: 12)),
                              onTap: () => onSelected(option),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              if (_selectedProduct != null) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Harga Saat Ini', style: TextStyle(fontWeight: FontWeight.w600, color: AppConstants.textLightColor, fontSize: 13)),
                          const SizedBox(height: 8),
                          Text(
                            AppConstants.currencyFormat.format(_selectedProduct!.price),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Harga Baru', style: TextStyle(fontWeight: FontWeight.w600, color: AppConstants.textLightColor, fontSize: 13)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _newPriceController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppConstants.primaryColor),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppConstants.backgroundColor,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              prefixText: 'Rp ',
                              prefixStyle: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Sesuaikan Harga', style: TextStyle(fontWeight: FontWeight.w600, color: AppConstants.textLightColor, fontSize: 13)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildAdjustBtn('-1.000', () => _adjustPrice(-1000), isNegative: true),
                    _buildAdjustBtn('-100', () => _adjustPrice(-100), isNegative: true),
                    _buildAdjustBtn('+100', () => _adjustPrice(100)),
                    _buildAdjustBtn('+1.000', () => _adjustPrice(1000)),
                  ],
                ),
              ],
              
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _selectedProduct == null 
                    ? null 
                    : () async {
                        final newPrice = int.tryParse(_newPriceController.text) ?? 0;
                        bool success = await priceLogProvider.updatePrice(
                          _selectedProduct!.id, 
                          _selectedProduct!.price, 
                          newPrice,
                        );
                        
                        if (success) {
                          if (context.mounted) {
                            Navigator.pop(context);
                            NavigationService.showSnackbar('Harga berhasil diperbarui!', isError: false);
                          }
                        }
                      },
                  child: const Text('Perbarui Harga Sekarang', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdjustBtn(String label, VoidCallback onTap, {bool isNegative = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isNegative ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isNegative ? Colors.red.withValues(alpha: 0.2) : Colors.green.withValues(alpha: 0.2)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isNegative ? Colors.red : Colors.green,
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
