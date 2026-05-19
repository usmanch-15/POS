// lib/providers/inventory_provider.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Inventory Provider (ChangeNotifier)
// ─────────────────────────────────────────────────────────────

import 'dart:async';
import 'package:flutter/material.dart';
import '../services/inventory_service.dart';
import '../models/product_model.dart';
import '../models/stock_model.dart';

class InventoryProvider extends ChangeNotifier {
  final InventoryService _service = InventoryService();

  List<StockMovement> _movements    = [];
  List<ProductModel>  _lowStock     = [];
  StockSummary?       _summary;
  bool                _isLoading    = false;
  String?             _error;
  StreamSubscription? _movSub;
  StreamSubscription? _lowSub;

  // ── Getters ────────────────────────────────────────────────
  List<StockMovement> get movements => _movements;
  List<ProductModel>  get lowStock  => _lowStock;
  StockSummary?       get summary   => _summary;
  bool                get isLoading => _isLoading;
  String?             get error     => _error;

  // ── Init ───────────────────────────────────────────────────
  void init() {
    _movSub = _service.streamMovements().listen((list) {
      _movements = list;
      notifyListeners();
    });
    _lowSub = _service.streamLowStockProducts().listen((list) {
      _lowStock = list;
      notifyListeners();
    });
    loadSummary();
  }

  // ── Load summary ───────────────────────────────────────────
  Future<void> loadSummary() async {
    try {
      _summary = await _service.getStockSummary();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ── Adjust stock ───────────────────────────────────────────
  Future<bool> adjustStock({
    required ProductModel product,
    required int          newQuantity,
    required String       reason,
    required String       addedBy,
    required StockMovementType type,
  }) async {
    _setLoading(true);
    try {
      await _service.adjustStock(
        product:     product,
        newQuantity: newQuantity,
        reason:      reason,
        addedBy:     addedBy,
        type:        type,
      );
      await loadSummary();
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // ── Stock In ───────────────────────────────────────────────
  Future<bool> stockIn({
    required String productId,
    required String productName,
    required int    currentQty,
    required int    addedQty,
    required String addedBy,
    String?         referenceId,
  }) async {
    _setLoading(true);
    try {
      await _service.stockIn(
        productId:   productId,
        productName: productName,
        currentQty:  currentQty,
        addedQty:    addedQty,
        addedBy:     addedBy,
        referenceId: referenceId,
      );
      await loadSummary();
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // ── Product movements ──────────────────────────────────────
  Stream<List<StockMovement>> productMovements(String productId) =>
      _service.streamProductMovements(productId);

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  @override
  void dispose() {
    _movSub?.cancel();
    _lowSub?.cancel();
    super.dispose();
  }
}
