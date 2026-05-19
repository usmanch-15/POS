// lib/providers/product_provider.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Product Provider (ChangeNotifier)
// ─────────────────────────────────────────────────────────────

import 'dart:async';
import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../models/product_model.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _service = ProductService();

  List<ProductModel> _products    = [];
  List<ProductModel> _filtered    = [];
  String             _searchQuery = '';
  String             _selectedCat = 'All';
  bool               _isLoading   = false;
  String?            _error;
  StreamSubscription? _sub;

  // ── Getters ────────────────────────────────────────────────
  List<ProductModel> get products    => _filtered;
  List<ProductModel> get allProducts => _products;
  bool               get isLoading   => _isLoading;
  String?            get error       => _error;
  String             get selectedCategory => _selectedCat;
  String             get searchQuery  => _searchQuery;

  List<ProductModel> get lowStockProducts =>
      _products.where((p) => p.isLowStock || p.isOutOfStock).toList();

  List<String> get categories {
    final cats = _products.map((p) => p.category).toSet().toList()..sort();
    return ['All', ...cats];
  }

  int get totalProducts  => _products.length;
  int get lowStockCount  => _products.where((p) => p.isLowStock).length;
  int get outOfStockCount => _products.where((p) => p.isOutOfStock).length;
  double get totalInventoryValue =>
      _products.fold(0.0, (s, p) => s + p.inventoryValue);

  // ── Init — start real-time stream ─────────────────────────
  void init() {
    _isLoading = true;
    notifyListeners();
    _sub = _service.streamProducts().listen(
      (list) {
        _products  = list;
        _isLoading = false;
        _error     = null;
        _applyFilters();
      },
      onError: (e) {
        _error     = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // ── Search ─────────────────────────────────────────────────
  void search(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  // ── Filter by category ─────────────────────────────────────
  void filterByCategory(String cat) {
    _selectedCat = cat;
    _applyFilters();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCat = 'All';
    _applyFilters();
  }

  void _applyFilters() {
    var list = List<ProductModel>.from(_products);
    if (_selectedCat != 'All') {
      list = list.where((p) => p.category == _selectedCat).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              (p.barcode?.contains(q) ?? false) ||
              p.category.toLowerCase().contains(q))
          .toList();
    }
    _filtered = list;
    notifyListeners();
  }

  // ── CRUD ───────────────────────────────────────────────────
  Future<bool> addProduct(ProductModel product) async {
    try {
      await _service.addProduct(product);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(ProductModel product) async {
    try {
      await _service.updateProduct(product);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      await _service.deleteProduct(id);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── Barcode lookup ─────────────────────────────────────────
  Future<ProductModel?> getByBarcode(String barcode) =>
      _service.getByBarcode(barcode);

  // ── Find in local list ─────────────────────────────────────
  ProductModel? findById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
