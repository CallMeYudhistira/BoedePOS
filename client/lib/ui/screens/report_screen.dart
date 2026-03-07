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
        borderRadius: AppConstants.largeBorderRadius,
        boxShadow: AppConstants.commonShadow,
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: AppConstants.primaryColor, size: 26),
              ),
              const SizedBox(width: 16),
              Text(
                title, 
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppConstants.textDarkColor, letterSpacing: -0.5),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildStatRow('Total Turnover', AppConstants.currencyFormat.format(report.totalTurnover), isHighlight: true),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(height: 1),
          ),
          _buildStatRow('Transactions', '${report.totalTransactions}'),
          const SizedBox(height: 8),
          _buildStatRow('Items Sold', '${report.totalItemsSold}'),
          if (report.mostSoldProductName != null) ...[
            const SizedBox(height: 8),
            _buildStatRow('Top Product', '${report.mostSoldProductName} (${report.mostSoldProductQty}x)'),
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: AppConstants.textLightColor, fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600)),
        Text(
          value, 
          style: TextStyle(
            fontSize: isHighlight ? 18 : 14, 
            fontWeight: FontWeight.w900, 
            color: isHighlight ? AppConstants.primaryColor : AppConstants.textDarkColor,
            letterSpacing: isHighlight ? -0.5 : 0,
          ),
        ),
      ],
    );
  }
}
