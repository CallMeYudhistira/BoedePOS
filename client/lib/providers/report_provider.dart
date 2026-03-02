import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/report.dart';

class ReportProvider with ChangeNotifier {
  SalesReport? _dailyReport;
  SalesReport? _weeklyReport;
  SalesReport? _monthlyReport;
  bool _isInitialLoading = true;

  SalesReport? get dailyReport => _dailyReport;
  SalesReport? get weeklyReport => _weeklyReport;
  SalesReport? get monthlyReport => _monthlyReport;
  bool get isLoading => _isInitialLoading && _dailyReport == null;

  Future<void> fetchReports() async {
    try {
      final results = await Future.wait([
        ApiClient.get('/transactions/reports?period=daily'),
        ApiClient.get('/transactions/reports?period=weekly'),
        ApiClient.get('/transactions/reports?period=monthly'),
      ]);

      if (results[0]['success'] == true) {
        _dailyReport = SalesReport.fromJson(results[0]['data']);
      }
      if (results[1]['success'] == true) {
        _weeklyReport = SalesReport.fromJson(results[1]['data']);
      }
      if (results[2]['success'] == true) {
        _monthlyReport = SalesReport.fromJson(results[2]['data']);
      }
    } catch (e) {
      print('Failed to fetch reports: $e');
    }
    _isInitialLoading = false;
    notifyListeners();
  }
}
