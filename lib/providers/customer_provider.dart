// lib/providers/customer_provider.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Customer Provider (ChangeNotifier)
// ─────────────────────────────────────────────────────────────

import 'dart:async';
import 'package:flutter/material.dart';
import '../services/customer_service.dart';
import '../models/customer_model.dart';

class CustomerProvider extends ChangeNotifier {
  final CustomerService _service = CustomerService();

  List<CustomerModel> _customers = [];
  List<CustomerModel> _filtered  = [];
  String              _query     = '';
  bool                _isLoading = false;
  String?             _error;
  StreamSubscription? _sub;

  // ── Getters ────────────────────────────────────────────────
  List<CustomerModel> get customers  => _filtered;
  List<CustomerModel> get allCustomers => _customers;
  bool                get isLoading  => _isLoading;
  String?             get error      => _error;
  int                 get totalCount => _customers.length;

  // ── Init ───────────────────────────────────────────────────
  void init() {
    _isLoading = true;
    notifyListeners();
    _sub = _service.streamCustomers().listen((list) {
      _customers = list;
      _isLoading = false;
      _applySearch();
    }, onError: (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  // ── Search ─────────────────────────────────────────────────
  void search(String query) {
    _query = query;
    _applySearch();
  }

  void _applySearch() {
    if (_query.isEmpty) {
      _filtered = List.from(_customers);
    } else {
      final q = _query.toLowerCase();
      _filtered = _customers
          .where((c) =>
              c.name.toLowerCase().contains(q) ||
              (c.phone?.contains(q) ?? false))
          .toList();
    }
    notifyListeners();
  }

  // ── CRUD ───────────────────────────────────────────────────
  Future<bool> addCustomer(CustomerModel customer) async {
    _setLoading(true);
    try {
      await _service.addCustomer(customer);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateCustomer(CustomerModel customer) async {
    _setLoading(true);
    try {
      await _service.updateCustomer(customer);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteCustomer(String id) async {
    _setLoading(true);
    try {
      await _service.deleteCustomer(id);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // ── Find by ID ─────────────────────────────────────────────
  CustomerModel? findById(String id) {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
