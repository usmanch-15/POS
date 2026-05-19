// lib/services/product_service.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Product Firestore Service
// ─────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _col => _db.collection('products');

  // ── Real-time stream ───────────────────────────────────────
  Stream<List<ProductModel>> streamProducts({bool activeOnly = true}) {
    Query query = _col.orderBy('name');
    if (activeOnly) query = query.where('isActive', isEqualTo: true);
    return query.snapshots().map((snap) => snap.docs
        .map((d) => ProductModel.fromFirestore(
              d.data() as Map<String, dynamic>, d.id))
        .toList());
  }

  // ── Low stock stream ───────────────────────────────────────
  Stream<List<ProductModel>> streamLowStock(int threshold) {
    return _col
        .where('quantity', isLessThanOrEqualTo: threshold)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ProductModel.fromFirestore(
                  d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  // ── Fetch all (one-time) ───────────────────────────────────
  Future<List<ProductModel>> getProducts() async {
    final snap = await _col
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .get();
    return snap.docs
        .map((d) => ProductModel.fromFirestore(
              d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  // ── Fetch single ───────────────────────────────────────────
  Future<ProductModel?> getProduct(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return ProductModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
  }

  // ── Search by barcode ──────────────────────────────────────
  Future<ProductModel?> getByBarcode(String barcode) async {
    final snap = await _col
        .where('barcode', isEqualTo: barcode)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return ProductModel.fromFirestore(
        snap.docs.first.data() as Map<String, dynamic>, snap.docs.first.id);
  }

  // ── Search by name ─────────────────────────────────────────
  Future<List<ProductModel>> searchByName(String query) async {
    final lower = query.toLowerCase();
    final snap  = await _col.where('isActive', isEqualTo: true).get();
    return snap.docs
        .map((d) => ProductModel.fromFirestore(
              d.data() as Map<String, dynamic>, d.id))
        .where((p) => p.name.toLowerCase().contains(lower) ||
            (p.barcode?.contains(lower) ?? false))
        .toList();
  }

  // ── Filter by category ─────────────────────────────────────
  Future<List<ProductModel>> getByCategory(String category) async {
    final snap = await _col
        .where('category', isEqualTo: category)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .get();
    return snap.docs
        .map((d) => ProductModel.fromFirestore(
              d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  // ── Add ────────────────────────────────────────────────────
  Future<ProductModel> addProduct(ProductModel product) async {
    final ref = await _col.add(product.toFirestore());
    return product.copyWith(id: ref.id);
  }

  // ── Update ─────────────────────────────────────────────────
  Future<void> updateProduct(ProductModel product) =>
      _col.doc(product.id).update(product.toFirestore());

  // ── Update quantity only (atomic) ─────────────────────────
  Future<void> updateQuantity(String productId, int newQty) =>
      _col.doc(productId).update({
        'quantity':  newQty,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  // ── Decrement quantity (after sale) ───────────────────────
  Future<void> decrementQuantity(String productId, int sold) =>
      _col.doc(productId).update({
        'quantity':  FieldValue.increment(-sold),
        'updatedAt': FieldValue.serverTimestamp(),
      });

  // ── Increment quantity (after purchase) ───────────────────
  Future<void> incrementQuantity(String productId, int added) =>
      _col.doc(productId).update({
        'quantity':  FieldValue.increment(added),
        'updatedAt': FieldValue.serverTimestamp(),
      });

  // ── Soft delete ────────────────────────────────────────────
  Future<void> deleteProduct(String productId) =>
      _col.doc(productId).update({'isActive': false});

  // ── Hard delete ────────────────────────────────────────────
  Future<void> permanentDelete(String productId) =>
      _col.doc(productId).delete();
}
