// lib/providers/report_provider.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Report Provider (ChangeNotifier)
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../services/report_service.dart';
import '../models/report_model.dart';

enum ReportPeriod { today, week, month, custom }

class ReportProvider extends ChangeNotifier {
  final ReportService _service = ReportService();

  DailySummary?      _dailySummary;
  MonthlySummary?    _monthlySummary;
  ProfitLossSummary? _profitLoss;
  List<TopProduct>   _topProducts   = [];
  List<CategorySales> _categorySales = [];
  List<ChartDataPoint> _weeklyChart  = [];

  ReportPeriod _period    = ReportPeriod.today;
  DateTime     _fromDate  = DateTime.now();
  DateTime     _toDate    = DateTime.now();
  bool         _isLoading = false;
  String?      _error;

  // ── Getters ────────────────────────────────────────────────
  DailySummary?       get dailySummary   => _dailySummary;
  MonthlySummary?     get monthlySummary => _monthlySummary;
  ProfitLossSummary?  get profitLoss     => _profitLoss;
  List<TopProduct>    get topProducts    => _topProducts;
  List<CategorySales> get categorySales  => _categorySales;
  List<ChartDataPoint> get weeklyChart   => _weeklyChart;
  ReportPeriod        get period         => _period;
  DateTime            get fromDate       => _fromDate;
  DateTime            get toDate         => _toDate;
  bool                get isLoading      => _isLoading;
  String?             get error          => _error;

  // ── Load today's daily summary ─────────────────────────────
  Future<void> loadDailySummary({DateTime? date}) async {
    _setLoading(true);
    try {
      _dailySummary = await _service.getDailySummary(date ?? DateTime.now());
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  // ── Load weekly chart ──────────────────────────────────────
  Future<void> loadWeeklyChart() async {
    _setLoading(true);
    try {
      _weeklyChart = await _service.getWeeklySalesChart();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  // ── Load monthly summary ───────────────────────────────────
  Future<void> loadMonthlySummary({int? month, int? year}) async {
    _setLoading(true);
    final now = DateTime.now();
    try {
      _monthlySummary = await _service.getMonthlySummary(
        month ?? now.month,
        year  ?? now.year,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  // ── Load profit & loss ─────────────────────────────────────
  Future<void> loadProfitLoss(DateTime from, DateTime to) async {
    _setLoading(true);
    _fromDate = from;
    _toDate   = to;
    try {
      _profitLoss = await _service.getProfitLoss(from, to);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  // ── Load top products ──────────────────────────────────────
  Future<void> loadTopProducts(DateTime from, DateTime to) async {
    _setLoading(true);
    try {
      _topProducts = await _service.getTopProducts(from: from, to: to);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  // ── Load category sales ────────────────────────────────────
  Future<void> loadCategorySales(DateTime from, DateTime to) async {
    _setLoading(true);
    try {
      _categorySales = await _service.getCategorySales(from: from, to: to);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  // ── Set period ─────────────────────────────────────────────
  void setPeriod(ReportPeriod period, {DateTime? from, DateTime? to}) {
    _period = period;
    final now = DateTime.now();
    switch (period) {
      case ReportPeriod.today:
        _fromDate = DateTime(now.year, now.month, now.day);
        _toDate   = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case ReportPeriod.week:
        _fromDate = now.subtract(const Duration(days: 6));
        _toDate   = now;
        break;
      case ReportPeriod.month:
        _fromDate = DateTime(now.year, now.month, 1);
        _toDate   = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;
      case ReportPeriod.custom:
        if (from != null) _fromDate = from;
        if (to   != null) _toDate   = to;
        break;
    }
    notifyListeners();
  }

  // ── Load dashboard data (all at once) ─────────────────────
  Future<void> loadDashboardData() async {
    await Future.wait([
      loadDailySummary(),
      loadWeeklyChart(),
    ]);
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
