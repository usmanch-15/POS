import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/sale_item_model.dart';
import '../models/sale_model.dart';
import '../services/sale_service.dart';
import '../services/local_storage_service.dart';

class CartProvider extends ChangeNotifier {
  final SaleService _service = SaleService();

  final List<SaleItemModel> _items          = [];
  final Map<String, int>    _availableStock = {};

  String?    _customerId;
  String?    _customerName;
  String?    _customerPhone;
  double     _discountAmount = 0;
  bool       _isLoading      = false;
  String?    _error;
  SaleModel? _lastSale;

  List<SaleItemModel> get items          => List.unmodifiable(_items);
  bool                get isEmpty        => _items.isEmpty;
  bool                get isLoading      => _isLoading;
  String?             get error          => _error;
  SaleModel?          get lastSale       => _lastSale;
  String?             get customerId     => _customerId;
  String?             get customerName   => _customerName;
  double              get discountAmount => _discountAmount;
  int                 get itemCount      => _items.fold(0, (s, i) => s + i.quantity);

  int  availableStockFor(String productId) => _availableStock[productId] ?? 0;
  bool canIncrement(String productId) {
    final idx = _items.indexWhere((i) => i.productId == productId);
    if (idx < 0) return false;
    return _items[idx].quantity < (_availableStock[productId] ?? 0);
  }

  double get subtotal    => _items.fold(0.0, (s, i) => s + i.total);
  double get taxRate     => LocalStorageService.gstRate;
  double get taxAmount   => subtotal * (taxRate / 100);
  double get grandTotal  => subtotal - _discountAmount + taxAmount;
  double get totalProfit => _items.fold(0.0, (s, i) => s + i.profit) - _discountAmount;
  double changeFor(double cash) => (cash - grandTotal).clamp(0, double.infinity);

  void addProduct(ProductModel product, {int quantity = 1}) {
    if (product.isOutOfStock) return;
    _availableStock[product.id] = product.quantity;
    final idx = _items.indexWhere((i) => i.productId == product.id);
    if (idx >= 0) {
      final newQty = _items[idx].quantity + quantity;
      if (newQty > product.quantity) return;
      _items[idx] = _items[idx].copyWith(quantity: newQty);
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

  void removeItem(String productId) {
    _items.removeWhere((i) => i.productId == productId);
    _availableStock.remove(productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int qty) {
    if (qty <= 0) { removeItem(productId); return; }
    final idx = _items.indexWhere((i) => i.productId == productId);
    if (idx < 0) return;
    final clamped = qty.clamp(1, _availableStock[productId] ?? qty);
    _items[idx] = _items[idx].copyWith(quantity: clamped);
    notifyListeners();
  }

  void increment(String productId) {
    final idx = _items.indexWhere((i) => i.productId == productId);
    if (idx < 0) return;
    if (_items[idx].quantity >= (_availableStock[productId] ?? 0)) return;
    _items[idx] = _items[idx].copyWith(quantity: _items[idx].quantity + 1);
    notifyListeners();
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

  void setCustomer({required String id, required String name, String? phone}) {
    _customerId    = id;
    _customerName  = name;
    _customerPhone = phone;
    notifyListeners();
  }

  void clearCustomer() {
    _customerId = _customerName = _customerPhone = null;
    notifyListeners();
  }

  void setDiscount(double amount) {
    _discountAmount = amount.clamp(0, subtotal);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _availableStock.clear();
    _discountAmount = 0;
    _customerId = _customerName = _customerPhone = null;
    _error      = null;
    _lastSale   = null;
    notifyListeners();
  }

  // FIX-6C: Safe checkout — cart clear sirf success pe hoti hai
  Future<SaleModel?> checkout({
    required PaymentMethod paymentMethod,
    double  cashReceived = 0,
    String? cashierId,
    String? cashierName,
    String? note,
  }) async {
    if (_items.isEmpty) return null;
    _setLoading(true);
    _error = null;

    // FIX-6C: Sale object pehle banao — cart items ki snapshot
    // Agar baad mein kuch fail ho to cart same rahegi
    final saleSnapshot = SaleModel(
      id:             '',
      billNumber:     '',
      items:          List.from(_items),   // deep copy
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

    try {
      // FIX-6C: Firestore transaction — agar yeh fail ho,
      // clearCart() call nahi hogi, cart intact rahegi
      _lastSale = await _service.completeSale(saleSnapshot);
      // Sirf success pe cart clear karo
      clearCart();
      _setLoading(false);
      return _lastSale;
    } catch (e) {
      // FIX-6C: Error set karo lekin cart NAHI clear karo
      // User dobara try kar sakta hai ya items adjust kar sakta hai
      _error = e.toString();
      _setLoading(false);
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
 