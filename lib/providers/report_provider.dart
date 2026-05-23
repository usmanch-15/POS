import 'package:flutter/material.dart';
import '../services/report_service.dart';
import '../models/report_model.dart';

enum ReportPeriod { today, week, month, custom }

class ReportProvider extends ChangeNotifier {
  final ReportService _service = ReportService();

  DailySummary?        _dailySummary;
  MonthlySummary?      _monthlySummary;
  ProfitLossSummary?   _profitLoss;
  List<TopProduct>     _topProducts   = [];
  List<CategorySales>  _categorySales = [];
  List<ChartDataPoint> _weeklyChart   = [];

  ReportPeriod _period    = ReportPeriod.today;
  DateTime     _fromDate  = DateTime.now();
  DateTime     _toDate    = DateTime.now();
  bool         _isLoading = false;
  String?      _error;

  DailySummary?        get dailySummary   => _dailySummary;
  MonthlySummary?      get monthlySummary => _monthlySummary;
  ProfitLossSummary?   get profitLoss     => _profitLoss;
  List<TopProduct>     get topProducts    => _topProducts;
  List<CategorySales>  get categorySales  => _categorySales;
  List<ChartDataPoint> get weeklyChart    => _weeklyChart;
  ReportPeriod         get period         => _period;
  DateTime             get fromDate       => _fromDate;
  DateTime             get toDate         => _toDate;
  bool                 get isLoading      => _isLoading;
  String?              get error          => _error;

  Future<void> loadDashboardData() => loadAll();

  Future<void> loadAll({DateTime? from, DateTime? to}) async {
    _isLoading = true;
    _error     = null;
    notifyListeners();

    final now      = DateTime.now();
    final fromDate = from ?? DateTime(now.year, now.month, 1);
    final toDate   = to   ?? now;

    try {
      final results = await Future.wait([
        _service.getDailySummary(now),
        _service.getMonthlySummary(now.month, now.year),
        _service.getWeeklySalesChart(),
        _service.getTopProducts(from: fromDate, to: toDate),  // named ✅
        _service.getCategorySales(from: fromDate, to: toDate), // named ✅
        _service.getProfitLoss(fromDate, toDate),              // ✅ FIX: positional
      ]);

      _dailySummary   = results[0] as DailySummary;
      _monthlySummary = results[1] as MonthlySummary;
      _weeklyChart    = results[2] as List<ChartDataPoint>;
      _topProducts    = results[3] as List<TopProduct>;
      _categorySales  = results[4] as List<CategorySales>;
      _profitLoss     = results[5] as ProfitLossSummary;
      _fromDate       = fromDate;
      _toDate         = toDate;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadForRange(DateTime from, DateTime to) async {
    _period = ReportPeriod.custom;
    await loadAll(from: from, to: to);
  }

  Future<void> loadDailySummary({DateTime? date}) async {
    try {
      _dailySummary = await _service.getDailySummary(date ?? DateTime.now());
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadMonthlySummary({int? month, int? year}) async {
    final now = DateTime.now();
    try {
      _monthlySummary = await _service.getMonthlySummary(
          month ?? now.month, year ?? now.year);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadWeeklyChart() async {
    try {
      _weeklyChart = await _service.getWeeklySalesChart();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadTopProducts(DateTime from, DateTime to) async {
    try {
      _topProducts = await _service.getTopProducts(from: from, to: to); // named ✅
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadCategorySales(DateTime from, DateTime to) async {
    try {
      _categorySales =
      await _service.getCategorySales(from: from, to: to); // named ✅
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadProfitLoss(DateTime from, DateTime to) async {
    try {
      _profitLoss =
      await _service.getProfitLoss(from, to); // ✅ FIX: positional
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}