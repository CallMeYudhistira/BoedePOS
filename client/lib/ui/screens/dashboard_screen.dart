import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/report_provider.dart';
import '../../core/constants.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
          final daily = provider.dailyReport;
          return RefreshIndicator(
            onRefresh: () => provider.fetchReports(),
            color: AppConstants.textDarkColor,
            backgroundColor: AppConstants.primaryColor,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const Text(
                  "Ringkasan Hari Ini",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppConstants.textDarkColor),
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  'Total Pendapatan', 
                  AppConstants.currencyFormat.format(daily?.totalTurnover ?? 0), 
                  Icons.monetization_on_rounded,
                  isPrimary: true,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildStatCard('Transaksi', '${daily?.totalTransactions ?? 0}', Icons.receipt_long_rounded)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard('Produk Terjual', '${daily?.totalItemsSold ?? 0}', Icons.shopping_bag_rounded)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, {bool isPrimary = false}) {
    return Container(
      decoration: BoxDecoration(
        color: isPrimary ? AppConstants.primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title, 
                style: TextStyle(
                  fontSize: 16, 
                  color: isPrimary ? Colors.white70 : AppConstants.textLightColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                icon, 
                size: 28, 
                color: isPrimary ? Colors.white : AppConstants.primaryColor,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value, 
            style: TextStyle(
              fontSize: isPrimary ? 32 : 24, 
              fontWeight: FontWeight.bold, 
              color: isPrimary ? Colors.white : AppConstants.textDarkColor,
            ),
          ),
        ],
      ),
    );
  }
}
