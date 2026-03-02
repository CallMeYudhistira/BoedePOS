import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/report_provider.dart';
import '../../core/constants.dart';
import '../../models/report.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().fetchReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Consumer<ReportProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor));
          }
          return RefreshIndicator(
            onRefresh: () => provider.fetchReports(),
            color: AppConstants.textDarkColor,
            backgroundColor: AppConstants.primaryColor,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildReportSection('Pendapatan Harian', provider.dailyReport, Icons.today),
                const SizedBox(height: 16),
                _buildReportSection('Pendapatan Mingguan', provider.weeklyReport, Icons.date_range),
                const SizedBox(height: 16),
                _buildReportSection('Pendapatan Bulanan', provider.monthlyReport, Icons.calendar_month),
                const SizedBox(height: 16),
                _buildReportSection('Pendapatan Tahunan', provider.yearlyReport, Icons.calendar_month),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReportSection(String title, SalesReport? report, IconData icon) {
    if (report == null) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppConstants.textDarkColor),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.textDarkColor)),
            ],
          ),
          const SizedBox(height: 20),
          _buildStatRow('Total Omzet', AppConstants.currencyFormat.format(report.totalTurnover), isHighlight: true),
          const Divider(height: 30),
          _buildStatRow('Total Transaksi', '${report.totalTransactions}'),
          _buildStatRow('Barang Terjual', '${report.totalItemsSold}'),
          if (report.mostSoldProductName != null)
            _buildStatRow('Produk Terlaris', '${report.mostSoldProductName} (${report.mostSoldProductQty}x)'),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isHighlight ? 16 : 15, color: AppConstants.textLightColor)),
          Text(
            value, 
            style: TextStyle(
              fontSize: isHighlight ? 20 : 16, 
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600, 
              color: isHighlight ? AppConstants.textDarkColor : AppConstants.textDarkColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
