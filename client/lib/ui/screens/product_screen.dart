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
                    product == null ? 'Add New Product' : 'Edit Product',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppConstants.textDarkColor),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Product Name',
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
                      labelText: 'Base Price (Rp)',
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
                      title: const Text('Is Fraction Item? (Variable Price)'),
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
                        backgroundColor: AppConstants.textDarkColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        final name = nameController.text;
                        final price = int.tryParse(priceController.text) ?? 0;
                        if (name.isEmpty || price <= 0) return;

                        if (product == null) {
                          await context.read<ProductProvider>().addProduct(name, price, isFraction);
                        } else {
                          await context.read<ProductProvider>().updateProduct(product.id, name, price, isFraction);
                        }
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: Text(product == null ? 'Save Product' : 'Update Product', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductDialog(),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: AppConstants.textDarkColor,
        icon: const Icon(Icons.add),
        label: const Text("New Product", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<ProductProvider>(
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
                  Center(child: Text('No products available.', style: TextStyle(color: Colors.grey, fontSize: 16))),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => provider.fetchProducts(),
            color: AppConstants.textDarkColor,
            backgroundColor: AppConstants.primaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 80),
              itemCount: provider.products.length,
              itemBuilder: (context, index) {
                final p = provider.products[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: p.isFraction ? Colors.orange.withOpacity(0.1) : AppConstants.primaryColor.withOpacity(0.2),
                      child: Icon(
                        p.isFraction ? Icons.scale : Icons.inventory_2,
                        color: p.isFraction ? Colors.orange : AppConstants.textDarkColor,
                      ),
                    ),
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text(
                      '${AppConstants.currencyFormat.format(p.price)} ${p.isFraction ? " (Fraction)" : ""}',
                      style: const TextStyle(color: AppConstants.textLightColor),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
                          onPressed: () => _showProductDialog(product: p),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () async {
                            bool confirm = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Product'),
                                content: Text('Are you sure you want to delete ${p.name}?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                    onPressed: () => Navigator.pop(context, true), 
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            ) ?? false;
                            if (confirm && context.mounted) {
                              context.read<ProductProvider>().deleteProduct(p.id);
                            }
                          },
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
    );
  }
}
