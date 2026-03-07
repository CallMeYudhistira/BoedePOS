import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../core/constants.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().fetchTransactions();
    });
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Riwayat Transaksi',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppConstants.textDarkColor, letterSpacing: -0.5),
                    ),
                    Text(
                      'Pantau catatan penjualan Anda',
                      style: TextStyle(fontSize: 12, color: AppConstants.textLightColor, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Consumer<TransactionProvider>(
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDateSelected ? AppConstants.primaryColor : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppConstants.commonShadow,
                        ),
                        child: Row(
                          children: [
                            if (isDateSelected) 
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Text(
                                  DateFormat('dd MMM').format(provider.selectedDate!),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                                ),
                              ),
                            Icon(
                              isDateSelected ? Icons.event_busy_rounded : Icons.calendar_month_rounded,
                              color: isDateSelected ? Colors.white : AppConstants.primaryColor,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor));
                }
                if (provider.transactions.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => provider.fetchTransactions(),
                    child: ListView(
                      children: const [
                        SizedBox(height: 100),
                        Center(child: Text('Tidak ada transaksi ditemukan.', style: TextStyle(color: Colors.grey, fontSize: 14))),
                      ],
                    ),
                  );
                }
                return Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => provider.fetchTransactions(),
                        color: AppConstants.textDarkColor,
                        backgroundColor: AppConstants.primaryColor,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: provider.transactions.length,
                          itemBuilder: (context, index) {
                            final t = provider.transactions[index];
                            final date = DateTime.tryParse(t.createdAt) ?? DateTime.now();
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: AppConstants.commonBorderRadius,
                                boxShadow: AppConstants.commonShadow,
                              ),
                              child: Theme(
                                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                child: ExpansionTile(
                                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  leading: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppConstants.backgroundColor,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(Icons.receipt_rounded, color: AppConstants.primaryColor, size: 26),
                                  ),
                                  title: Text(
                                    'Order #INV-${t.id.toString().padLeft(4, '0')}', 
                                    style: const TextStyle(fontWeight: FontWeight.w900, color: AppConstants.textDarkColor, fontSize: 14),
                                  ),
                                  subtitle: Text(
                                    DateFormat('dd MMM yyyy • HH:mm').format(date), 
                                    style: const TextStyle(color: AppConstants.textLightColor, fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                  trailing: Text(
                                    AppConstants.currencyFormat.format(t.total),
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppConstants.primaryColor, letterSpacing: -0.5),
                                  ),
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16.0),
                                      decoration: BoxDecoration(
                                        color: AppConstants.backgroundColor.withValues(alpha: 0.5),
                                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ...t.details.map((d) => Padding(
                                            padding: const EdgeInsets.only(bottom: 10.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: AppConstants.primaryColor.withValues(alpha: 0.1),
                                                          borderRadius: BorderRadius.circular(6),
                                                        ),
                                                        child: Text('${d.qty}x', style: const TextStyle(fontWeight: FontWeight.w900, color: AppConstants.primaryColor, fontSize: 11)),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Expanded(child: Text(d.productName, style: const TextStyle(fontWeight: FontWeight.w700, color: AppConstants.textDarkColor, fontSize: 13))),
                                                    ],
                                                  ),
                                                ),
                                                Text(AppConstants.currencyFormat.format(d.subtotal), style: const TextStyle(fontWeight: FontWeight.w800, color: AppConstants.textDarkColor, fontSize: 13)),
                                              ],
                                            ),
                                          )),
                                          const Padding(
                                            padding: EdgeInsets.symmetric(vertical: 8.0),
                                            child: Divider(height: 1),
                                          ),
                                          _buildDetailRow('Jumlah Bayar', AppConstants.currencyFormat.format(t.pay)),
                                          const SizedBox(height: 4),
                                          _buildDetailRow('Kembalian', AppConstants.currencyFormat.format(t.change), isHighlighted: true),
                                        ],
                                      ),
                                    ),
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
    );
  }

  Widget _buildPaginationControls(TransactionProvider provider) {
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

  Widget _buildDetailRow(String label, String value, {bool isHighlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppConstants.textLightColor, fontWeight: FontWeight.w600, fontSize: 14)),
        Text(
          value, 
          style: TextStyle(
            fontWeight: FontWeight.w900, 
            color: isHighlighted ? Colors.green : AppConstants.textDarkColor,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
