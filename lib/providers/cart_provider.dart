// lib/providers/cart_provider.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Cart / POS Provider (ChangeNotifier)
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/sale_item_model.dart';
import '../models/sale_model.dart';
import '../services/sale_service.dart';
import '../services/local_storage_service.dart';

class CartProvider extends ChangeNotifier {
  final SaleService _service = SaleService();

  final List<SaleItemModel> _items  = [];
  String?  _customerId;
  String?  _customerName;
  String?  _customerPhone;
  double   _discountAmount = 0;
  bool     _isLoading      = false;
  String?  _error;
  SaleModel? _lastSale;

  // ── Getters ────────────────────────────────────────────────
  List<SaleItemModel> get items         => List.unmodifiable(_items);
  bool                get isEmpty       => _items.isEmpty;
  bool                get isLoading     => _isLoading;
  String?             get error         => _error;
  SaleModel?          get lastSale      => _lastSale;
  String?             get customerId    => _customerId;
  String?             get customerName  => _customerName;
  double              get discountAmount => _discountAmount;
  int                 get itemCount     => _items.fold(0, (s, i) => s + i.quantity);

  // ── Computed totals ────────────────────────────────────────
  double get subtotal =>
      _items.fold(0.0, (s, i) => s + i.total);

  double get taxRate   => LocalStorageService.gstRate;
  double get taxAmount => subtotal * (taxRate / 100);

  double get grandTotal =>
      subtotal - _discountAmount + taxAmount;

  double get totalProfit =>
      _items.fold(0.0, (s, i) => s + i.profit) - _discountAmount;

  double changeFor(double cashReceived) =>
      (cashReceived - grandTotal).clamp(0, double.infinity);

  // ── Add product to cart ────────────────────────────────────
  void addProduct(ProductModel product, {int quantity = 1}) {
    if (product.isOutOfStock) return;

    final idx = _items.indexWhere((i) => i.productId == product.id);
    if (idx >= 0) {
      final existing = _items[idx];
      final newQty   = existing.quantity + quantity;
      // Don't exceed available stock
      if (newQty > product.quantity) return;
      _items[idx] = existing.copyWith(quantity: newQty);
    } else {
      _items.add(SaleItemModel(
        productId:   product.id,
        productName: product.name,
        barcode:     product.barcode,
        category:    product.category,
        quantity:    quantity,
        salePrice:   product.salePrice,
        costPrice:   product.costPrice,
      ));
    }
    notifyListeners();
  }

  // ── Remove one item ────────────────────────────────────────
  void removeItem(String productId) {
    _items.removeWhere((i) => i.productId == productId);
    notifyListeners();
  }

  // ── Update quantity ────────────────────────────────────────
  void updateQuantity(String productId, int qty) {
    if (qty <= 0) {
      removeItem(productId);
      return;
    }
    final idx = _items.indexWhere((i) => i.productId == productId);
    if (idx >= 0) {
      _items[idx] = _items[idx].copyWith(quantity: qty);
      notifyListeners();
    }
  }

  // ── Increment / Decrement ──────────────────────────────────
  void increment(String productId) {
    final idx = _items.indexWhere((i) => i.productId == productId);
    if (idx >= 0) {
      _items[idx] = _items[idx].copyWith(quantity: _items[idx].quantity + 1);
      notifyListeners();
    }
  }

  void decrement(String productId) {
    final idx = _items.indexWhere((i) => i.productId == productId);
    if (idx < 0) return;
    if (_items[idx].quantity <= 1) {
      removeItem(productId);
    } else {
      _items[idx] = _items[idx].copyWith(quantity: _items[idx].quantity - 1);
      notifyListeners();
    }
  }

  // ── Set customer ───────────────────────────────────────────
  void setCustomer({
    required String id,
    required String name,
    String? phone,
  }) {
    _customerId   = id;
    _customerName = name;
    _customerPhone = phone;
    notifyListeners();
  }

  void clearCustomer() {
    _customerId   = null;
    _customerName = null;
    _customerPhone = null;
    notifyListeners();
  }

  // ── Set discount ───────────────────────────────────────────
  void setDiscount(double amount) {
    _discountAmount = amount.clamp(0, subtotal);
    notifyListeners();
  }

  // ── Clear cart ─────────────────────────────────────────────
  void clearCart() {
    _items.clear();
    _discountAmount = 0;
    _customerId     = null;
    _customerName   = null;
    _customerPhone  = null;
    _error          = null;
    _lastSale       = null;
    notifyListeners();
  }

  // ── Checkout ───────────────────────────────────────────────
  Future<SaleModel?> checkout({
    required PaymentMethod paymentMethod,
    double cashReceived = 0,
    String? cashierId,
    String? cashierName,
    String? note,
  }) async {
    if (_items.isEmpty) return null;
    _setLoading(true);

    try {
      final sale = SaleModel(
        id:             '',
        billNumber:     '',
        items:          List.from(_items),
        subtotal:       subtotal,
        discountAmount: _discountAmount,
        taxAmount:      taxAmount,
        taxRate:        taxRate,
        total:          grandTotal,
        paymentMethod:  paymentMethod,
        customerId:     _customerId,
        customerName:   _customerName,
        customerPhone:  _customerPhone,
        cashierId:      cashierId,
        cashierName:    cashierName,
        cashReceived:   cashReceived,
        changeGiven:    changeFor(cashReceived),
        note:           note,
        createdAt:      DateTime.now(),
      );

      _lastSale = await _service.completeSale(sale);
      clearCart();
      _setLoading(false);
      return _lastSale;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return null;
    }
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
