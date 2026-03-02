import 'package:flutter/material.dart';
import '../../core/constants.dart';
import 'dashboard_screen.dart';
import 'pos_screen.dart';
import 'history_screen.dart';
import 'product_screen.dart';
import 'report_screen.dart';
import 'price_logs_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardScreen(),
    const PosScreen(),
    const HistoryScreen(),
    const ProductScreen(),
    const PriceLogsScreen(),
    const ReportScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BoedePOS'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white, // Since primary is dark blue
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: AppConstants.primaryColor,
              ),
              child: Text(
                'Menu BoedePOS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildDrawerItem(Icons.dashboard, 'Beranda', 0),
            _buildDrawerItem(Icons.point_of_sale, 'Transaksi (POS)', 1),
            _buildDrawerItem(Icons.history, 'Riwayat Transaksi', 2),
            _buildDrawerItem(Icons.inventory, 'Manajemen Produk', 3),
            _buildDrawerItem(Icons.price_change, 'Monitoring Harga', 4),
            _buildDrawerItem(Icons.analytics, 'Laporan', 5),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_selectedIndex),
          child: _pages[_selectedIndex],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: _selectedIndex == index ? AppConstants.primaryColor : Colors.grey),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: _selectedIndex == index ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: _selectedIndex == index,
      selectedTileColor: AppConstants.primaryColor.withOpacity(0.1),
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.pop(context);
      },
    );
  }
}
