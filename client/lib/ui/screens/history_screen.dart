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
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Riwayat Transaksi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.textDarkColor),
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
                        child: Row(
                          children: [
                            if (isDateSelected) 
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Text(
                                  DateFormat('dd MMM yyyy').format(provider.selectedDate!),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            Icon(
                              isDateSelected ? Icons.event_busy : Icons.calendar_today,
                              color: isDateSelected ? Colors.white : AppConstants.textDarkColor,
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
                        Center(child: Text('Tidak ada transaksi ditemukan.', style: TextStyle(color: Colors.grey, fontSize: 16))),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => provider.fetchTransactions(),
                  color: AppConstants.textDarkColor,
                  backgroundColor: AppConstants.primaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: provider.transactions.length,
                    itemBuilder: (context, index) {
                      final t = provider.transactions[index];
                      final date = DateTime.tryParse(t.createdAt) ?? DateTime.now();
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
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
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppConstants.primaryColor.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.receipt_long_rounded, color: AppConstants.textDarkColor),
                            ),
                            title: Text('INV-${t.id.toString().padLeft(6, '0')}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppConstants.textDarkColor)),
                            subtitle: Text(DateFormat('dd MMM yyyy • HH:mm').format(date), style: const TextStyle(color: AppConstants.textLightColor, fontSize: 13)),
                            trailing: Text(
                              AppConstants.currencyFormat.format(t.total),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppConstants.textDarkColor),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ...t.details.map((d) => Padding(
                                      padding: const EdgeInsets.only(bottom: 12.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text('${d.qty}x', style: const TextStyle(fontWeight: FontWeight.bold, color: AppConstants.textLightColor)),
                                              const SizedBox(width: 8),
                                              Text(d.productName, style: const TextStyle(fontWeight: FontWeight.w500)),
                                            ],
                                          ),
                                          Text(AppConstants.currencyFormat.format(d.subtotal), style: const TextStyle(fontWeight: FontWeight.w500)),
                                        ],
                                      ),
                                    )),
                                    const Divider(height: 24),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Total Bayar', style: TextStyle(color: AppConstants.textLightColor)),
                                        Text(AppConstants.currencyFormat.format(t.pay), style: const TextStyle(fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Kembalian', style: TextStyle(color: AppConstants.textLightColor)),
                                        Text(AppConstants.currencyFormat.format(t.change), style: const TextStyle(fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ],
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
    );
  }
}
