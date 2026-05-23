import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _col => _db.collection('products');

  String get _businessId {
    final token = FirebaseAuth.instance.currentUser?.uid;
    if (token == null) throw Exception('User logged in nahi hai');
    return _cachedBusinessId;
  }

  // businessId cache — AuthProvider login ke baad set karega
  static String _cachedBusinessId = '';

  /// AuthProvider se call karo login ke baad
  static void setBusinessId(String id) {
    _cachedBusinessId = id;
  }

  // ✅ FIX: Public getter — SaleService aur doosri services access kar sakti hain
  static String get cachedBusinessId => _cachedBusinessId;

  // ── Real-time stream ───────────────────────────────────────
  Stream<List<ProductModel>> streamProducts({bool activeOnly = true}) {
    Query query = _col
        .where('businessId', isEqualTo: _cachedBusinessId)
        .orderBy('name');
    if (activeOnly) query = query.where('isActive', isEqualTo: true);
    return query.snapshots().map(_mapProducts);
  }

  // ── Low stock stream ───────────────────────────────────────
  Stream<List<ProductModel>> streamLowStock(int threshold) {
    return _col
        .where('businessId', isEqualTo: _cachedBusinessId)
        .where('quantity', isLessThanOrEqualTo: threshold)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(_mapProducts);
  }

  // ── Fetch all (one-time) ───────────────────────────────────
  Future<List<ProductModel>> getProducts() async {
    final snap = await _col
        .where('businessId', isEqualTo: _cachedBusinessId)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .get();
    return _mapProducts(snap);
  }

  // ── Fetch single ───────────────────────────────────────────
  Future<ProductModel?> getProduct(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>;
    if (data['businessId'] != _cachedBusinessId) return null;
    return ProductModel.fromFirestore(data, doc.id);
  }

  // ── Search by barcode ──────────────────────────────────────
  Future<ProductModel?> getByBarcode(String barcode) async {
    final snap = await _col
        .where('businessId', isEqualTo: _cachedBusinessId)
        .where('barcode', isEqualTo: barcode)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return ProductModel.fromFirestore(
        snap.docs.first.data() as Map<String, dynamic>, snap.docs.first.id);
  }

  // ── Search by name (prefix query) ─────────────────────────
  Future<List<ProductModel>> searchByName(String query) async {
    if (query.trim().isEmpty) return getProducts();

    final lower = query.toLowerCase().trim();
    final end = lower.substring(0, lower.length - 1) +
        String.fromCharCode(lower.codeUnitAt(lower.length - 1) + 1);

    final snap = await _col
        .where('businessId', isEqualTo: _cachedBusinessId)
        .where('isActive', isEqualTo: true)
        .where('nameLower', isGreaterThanOrEqualTo: lower)
        .where('nameLower', isLessThan: end)
        .orderBy('nameLower')
        .limit(50)
        .get();

    return _mapProducts(snap);
  }

  // ── Filter by category ─────────────────────────────────────
  Future<List<ProductModel>> getByCategory(String category) async {
    final snap = await _col
        .where('businessId', isEqualTo: _cachedBusinessId)
        .where('category', isEqualTo: category)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .get();
    return _mapProducts(snap);
  }

  // ── Add ────────────────────────────────────────────────────
  Future<ProductModel> addProduct(ProductModel product) async {
    final data = product.toFirestore();
    data['nameLower'] = product.name.toLowerCase();
    data['businessId'] = _cachedBusinessId;
    final ref = await _col.add(data);
    return product.copyWith(id: ref.id);
  }

  // ── Update ─────────────────────────────────────────────────
  Future<void> updateProduct(ProductModel product) {
    final data = product.toFirestore();
    data['nameLower'] = product.name.toLowerCase();
    data['businessId'] = _cachedBusinessId;
    return _col.doc(product.id).update(data);
  }

  // ── Stock snapshot — sirf transaction ke liye ──────────────
  Future<int> getStockSnapshot(Transaction txn, String productId) async {
    final snap = await txn.get(_col.doc(productId));
    if (!snap.exists) return 0;
    return (snap.data() as Map<String, dynamic>)['quantity'] as int? ?? 0;
  }

  // ── Controlled stock adjustment (public) ──────────────────
  Future<void> adjustStock({
    required String productId,
    required int delta,
    required String reason,
  }) async {
    if (delta == 0) return;
    await _col.doc(productId).update({
      'quantity': FieldValue.increment(delta),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastAdjustmentReason': reason,
    });
  }

  // ── Transaction helpers ────────────────────────────────────
  void _applyDecrementInTransaction(
      Transaction txn, String productId, int quantity) {
    txn.update(_col.doc(productId), {
      'quantity': FieldValue.increment(-quantity),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  void _applyIncrementInTransaction(
      Transaction txn, String productId, int quantity) {
    txn.update(_col.doc(productId), {
      'quantity': FieldValue.increment(quantity),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  void applyDecrementInTxn(Transaction txn, String productId, int qty) =>
      _applyDecrementInTransaction(txn, productId, qty);

  void applyIncrementInTxn(Transaction txn, String productId, int qty) =>
      _applyIncrementInTransaction(txn, productId, qty);

  // ── Soft delete ────────────────────────────────────────────
  Future<void> deleteProduct(String productId) =>
      _col.doc(productId).update({'isActive': false});

  // ── Hard delete (admin only) ───────────────────────────────
  Future<void> permanentDelete(String productId) =>
      _col.doc(productId).delete();

  // ── Helper ─────────────────────────────────────────────────
  List<ProductModel> _mapProducts(QuerySnapshot snap) => snap.docs
      .map((d) => ProductModel.fromFirestore(
      d.data() as Map<String, dynamic>, d.id))
      .toList();
}