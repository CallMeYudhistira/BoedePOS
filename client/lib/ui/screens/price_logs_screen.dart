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
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => context.read<PriceLogProvider>().setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Cari berdasarkan produk...',
                      prefixIcon: const Icon(Icons.search, color: AppConstants.textLightColor),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
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
                          );
                          if (date != null) provider.setSelectedDate(date);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDateSelected ? AppConstants.primaryColor : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isDateSelected ? Icons.event_busy : Icons.calendar_today,
                          color: isDateSelected ? Colors.white : AppConstants.textDarkColor,
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
                        Center(child: Text('Tidak ada riwayat harga.', style: TextStyle(color: Colors.grey, fontSize: 16))),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => provider.fetchPriceLogs(),
                  color: AppConstants.textDarkColor,
                  backgroundColor: AppConstants.primaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
                    itemCount: provider.priceLogs.length,
                    itemBuilder: (context, index) {
                      final log = provider.priceLogs[index];
                      final isUp = log.newPrice > log.oldPrice;
                      final isDown = log.newPrice < log.oldPrice;
                      final date = DateTime.tryParse(log.createdAt) ?? DateTime.now();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: ListTile(
                          onTap: log.product != null ? () => _showAddPriceLogSheet(initialProduct: log.product) : null,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          leading: CircleAvatar(
                            backgroundColor: isUp
                                ? Colors.red.withValues(alpha: 0.1)
                                : isDown
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.grey.withValues(alpha: 0.1),
                            child: Icon(
                              isUp
                                  ? Icons.trending_up
                                  : isDown
                                      ? Icons.trending_down
                                      : Icons.trending_flat,
                              color: isUp ? Colors.red : isDown ? Colors.green : Colors.grey,
                            ),
                          ),
                          title: Text(
                            log.product?.name ?? 'Produk Tidak Diketahui',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppConstants.textDarkColor),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    AppConstants.currencyFormat.format(log.oldPrice),
                                    style: const TextStyle(
                                      color: AppConstants.textLightColor,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward, size: 14, color: AppConstants.textLightColor),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppConstants.currencyFormat.format(log.newPrice),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isUp ? Colors.red : isDown ? Colors.green : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('dd MMM yyyy • HH:mm').format(date),
                                style: const TextStyle(color: AppConstants.textLightColor, fontSize: 12),
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
    }
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
                'Update Harga Produk',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppConstants.textDarkColor),
              ),
              const SizedBox(height: 24),
              
              const Text('Pilih Produk', style: TextStyle(fontWeight: FontWeight.w600, color: AppConstants.textLightColor)),
              const SizedBox(height: 8),
              
              Autocomplete<Product>(
                displayStringForOption: (Product p) => p.name,
                initialValue: TextEditingValue(text: _selectedProduct?.name ?? ''),
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<Product>.empty();
                  }
                  return products.where((Product p) {
                    return p.name.toLowerCase().contains(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (Product p) {
                  setState(() {
                    _selectedProduct = p;
                  });
                },
                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                  // Link the controller if not already linked
                  if (controller.text.isEmpty && _selectedProduct != null) {
                    controller.text = _selectedProduct!.name;
                  }
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      hintText: 'Cari produk...',
                      filled: true,
                      fillColor: AppConstants.backgroundColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.search),
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
                              title: Text(option.name),
                              subtitle: Text(AppConstants.currencyFormat.format(option.price)),
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
                          const Text('Harga Saat Ini', style: TextStyle(fontWeight: FontWeight.w600, color: AppConstants.textLightColor)),
                          const SizedBox(height: 8),
                          Text(
                            AppConstants.currencyFormat.format(_selectedProduct!.price),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Harga Baru', style: TextStyle(fontWeight: FontWeight.w600, color: AppConstants.textLightColor)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _newPriceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: '0',
                              errorText: priceLogProvider.validationErrors['new_price'],
                              filled: true,
                              fillColor: AppConstants.backgroundColor,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                  child: const Text('Perbarui Harga Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      }
    );
  }
}
