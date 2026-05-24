import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/report_service.dart';
import '../models/report_model.dart';
import '../models/sale_model.dart';
import '../services/product_service.dart';

enum ReportPeriod { today, week, month, custom }

class ReportProvider extends ChangeNotifier {
  final ReportService      _service = ReportService();
  final FirebaseFirestore  _db      = FirebaseFirestore.instance;

  DailySummary?        _dailySummary;
  MonthlySummary?      _monthlySummary;
  ProfitLossSummary?   _profitLoss;
  List<TopProduct>     _topProducts   = [];
  List<CategorySales>  _categorySales = [];
  List<ChartDataPoint> _weeklyChart   = [];

  // Live today stats — stream se aate hain
  double _todayRevenue  = 0;
  double _todayProfit   = 0;
  int    _todayBills    = 0;

  ReportPeriod _period    = ReportPeriod.today;
  DateTime     _fromDate  = DateTime.now();
  DateTime     _toDate    = DateTime.now();
  bool         _isLoading = false;
  String?      _error;

  StreamSubscription? _todayStreamSub;

  // ── Getters ────────────────────────────────────────────────
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

  // Live stats getters
  double get todayRevenue => _todayRevenue;
  double get todayProfit  => _todayProfit;
  int    get todayBills   => _todayBills;

  // ✅ FIX: dashboard_screen line 83 — monthly revenue
  double get monthRevenue => _monthlySummary?.totalSales ?? _todayRevenue;

  // ✅ FIX: dashboard_screen line 99 — monthly profit
  double get monthProfit  => _monthlySummary?.totalProfit ?? _todayProfit;

  // ── startTodayStream ───────────────────────────────────────
  void startTodayStream() {
    _todayStreamSub?.cancel();

    final now  = DateTime.now();
    final from = DateTime(now.year, now.month, now.day);
    final to   = DateTime(now.year, now.month, now.day, 23, 59, 59);

    _todayStreamSub = _db
        .collection('sales')
        .where('businessId',
        isEqualTo: ProductService.cachedBusinessId)
        .where('status',
        isEqualTo: SaleStatus.completed.name)
        .where('createdAt',
        isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('createdAt',
        isLessThanOrEqualTo: Timestamp.fromDate(to))
        .snapshots()
        .listen((snap) {
      final sales = snap.docs
          .map((d) => SaleModel.fromFirestore(
          d.data() as Map<String, dynamic>, d.id))
          .toList();

      _todayRevenue = sales.fold(0.0, (s, sale) => s + sale.total);
      _todayProfit  = sales.fold(0.0, (s, sale) => s + sale.totalProfit);
      _todayBills   = sales.length;

      _dailySummary = DailySummary(
        date:          now,
        totalSales:    _todayRevenue,
        totalCost:     sales.fold(0.0, (s, sale) => s + sale.totalCost),
        totalProfit:   _todayProfit,
        totalDiscount: sales.fold(0.0, (s, sale) => s + sale.discountAmount),
        billCount:     _todayBills,
        itemsSold:     sales.fold(0, (s, sale) => s + sale.totalItems),
      );

      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      notifyListeners();
    });
  }

  // ── loadDashboardData ──────────────────────────────────────
  Future<void> loadDashboardData() async {
    startTodayStream();
    _loadOtherStats();
  }

  Future<void> _loadOtherStats() async {
    final now      = DateTime.now();
    final fromDate = DateTime(now.year, now.month, 1);

    try {
      final results = await Future.wait([
        _service.getMonthlySummary(now.month, now.year),
        _service.getWeeklySalesChart(),
        _service.getTopProducts(from: fromDate, to: now),
        _service.getCategorySales(from: fromDate, to: now),
        _service.getProfitLoss(fromDate, now),
      ]);

      _monthlySummary = results[0] as MonthlySummary;
      _weeklyChart    = results[1] as List<ChartDataPoint>;
      _topProducts    = results[2] as List<TopProduct>;
      _categorySales  = results[3] as List<CategorySales>;
      _profitLoss     = results[4] as ProfitLossSummary;
      _fromDate       = fromDate;
      _toDate         = now;
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> loadForRange(DateTime from, DateTime to) async {
    _period    = ReportPeriod.custom;
    _isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _service.getTopProducts(from: from, to: to),
        _service.getCategorySales(from: from, to: to),
        _service.getProfitLoss(from, to),
      ]);
      _topProducts   = results[0] as List<TopProduct>;
      _categorySales = results[1] as List<CategorySales>;
      _profitLoss    = results[2] as ProfitLossSummary;
      _fromDate      = from;
      _toDate        = to;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
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
      _topProducts = await _service.getTopProducts(from: from, to: to);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadCategorySales(DateTime from, DateTime to) async {
    try {
      _categorySales = await _service.getCategorySales(from: from, to: to);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadProfitLoss(DateTime from, DateTime to) async {
    try {
      _profitLoss = await _service.getProfitLoss(from, to);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _todayStreamSub?.cancel();
    super.dispose();
  }
}