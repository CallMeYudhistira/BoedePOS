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
              padding: const EdgeInsets.all(20.0),
              children: [
                const Text(
                  "Ringkasan Hari Ini",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppConstants.textDarkColor, letterSpacing: -0.5),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Ringkasan bisnis Anda hari ini",
                  style: TextStyle(fontSize: 12, color: AppConstants.textLightColor, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 24),
                _buildStatCard(
                  'Total Pendapatan', 
                  AppConstants.currencyFormat.format(daily?.totalTurnover ?? 0), 
                  Icons.monetization_on_rounded,
                  isPrimary: true,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildStatCard('Pesanan', '${daily?.totalTransactions ?? 0}', Icons.receipt_long_rounded)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard('Produk Terjual', '${daily?.totalItemsSold ?? 0}', Icons.shopping_basket_rounded)),
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
        borderRadius: AppConstants.largeBorderRadius,
        boxShadow: AppConstants.commonShadow,
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isPrimary ? Colors.white.withValues(alpha: 0.2) : AppConstants.backgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon, 
              size: 32, 
              color: isPrimary ? Colors.white : AppConstants.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title, 
            style: TextStyle(
              fontSize: 14, 
              color: isPrimary ? Colors.white70 : AppConstants.textLightColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value, 
              style: TextStyle(
                fontSize: isPrimary ? 28 : 22, 
                fontWeight: FontWeight.w900, 
                color: isPrimary ? Colors.white : AppConstants.textDarkColor,
                letterSpacing: -1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
