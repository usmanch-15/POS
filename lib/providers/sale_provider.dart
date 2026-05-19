// lib/providers/sale_provider.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Sale History Provider (ChangeNotifier)
// ─────────────────────────────────────────────────────────────

import 'dart:async';
import 'package:flutter/material.dart';
import '../services/sale_service.dart';
import '../models/sale_model.dart';

class SaleProvider extends ChangeNotifier {
  final SaleService _service = SaleService();

  List<SaleModel> _sales      = [];
  List<SaleModel> _todaySales = [];
  bool            _isLoading  = false;
  String?         _error;
  StreamSubscription? _todaySub;

  // ── Getters ────────────────────────────────────────────────
  List<SaleModel> get sales       => _sales;
  List<SaleModel> get todaySales  => _todaySales;
  bool            get isLoading   => _isLoading;
  String?         get error       => _error;

  // ── Today's stats ──────────────────────────────────────────
  double get todayRevenue =>
      _todaySales.fold(0.0, (s, sale) => s + sale.total);

  double get todayProfit =>
      _todaySales.fold(0.0, (s, sale) => s + sale.totalProfit);

  int get todayBillCount => _todaySales.length;

  double get todayAvgBill =>
      todayBillCount > 0 ? todayRevenue / todayBillCount : 0;

  // ── Init today's live stream ───────────────────────────────
  void initToday() {
    _todaySub = _service.streamTodaySales().listen(
      (list) {
        _todaySales = list;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  // ── Load all sales ─────────────────────────────────────────
  Future<void> loadSales() async {
    _setLoading(true);
    try {
      // Use stream for live updates
      _service.streamSales().listen((list) {
        _sales     = list;
        _isLoading = false;
        _error     = null;
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  // ── Load by date range ─────────────────────────────────────
  Future<List<SaleModel>> loadByRange(DateTime from, DateTime to) async {
    _setLoading(true);
    try {
      final list = await _service.getSalesInRange(from, to);
      _sales = list;
      _setLoading(false);
      return list;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return [];
    }
  }

  // ── Refund ─────────────────────────────────────────────────
  Future<bool> refundSale(String saleId) async {
    _setLoading(true);
    try {
      await _service.refundSale(saleId);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // ── Get single ─────────────────────────────────────────────
  Future<SaleModel?> getSale(String id) => _service.getSale(id);

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  @override
  void dispose() {
    _todaySub?.cancel();
    super.dispose();
  }
}
