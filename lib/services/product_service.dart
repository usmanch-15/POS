// lib/services/product_service.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Product Firestore Service
//  FIX: searchByName() poori collection load karta tha Dart mein
//       filter karne ke liye — 1000+ products pe bahut slow.
//       Ab Firestore prefix query use hoti hai (startAt/endAt).
//       Yeh sirf matching range ke documents fetch karta hai.
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

  // ── Search by name — FIX ───────────────────────────────────
  // PEHLE: Saare products load karta tha, Dart mein contains() filter.
  //        1000 products = 1000 Firestore reads har search pe.
  //
  // AB:    Firestore prefix query — sirf us range ke documents aate hain
  //        jo query string se shuru hote hain.
  //        Example: "che" search → "Cheese", "Cheetos" etc. milenge.
  //
  // NOTE:  Firestore mein mid-word search nahi hoti (jaise "heese" se
  //        "Cheese" nahi milega). Iske liye Algolia best option hai.
  //        Yeh fix basic name search ko fast banata hai.
  //
  // Firestore Index zaroori:  isActive ASC + nameLower ASC
  Future<List<ProductModel>> searchByName(String query) async {
    if (query.trim().isEmpty) return getProducts();

    final lower = query.toLowerCase().trim();
    final end   = lower.substring(0, lower.length - 1) +
        String.fromCharCode(lower.codeUnitAt(lower.length - 1) + 1);

    // Prefix range query — sirf matching documents fetch hote hain
    final snap = await _col
        .where('isActive',   isEqualTo: true)
        .where('nameLower',  isGreaterThanOrEqualTo: lower)
        .where('nameLower',  isLessThan: end)
        .orderBy('nameLower')
        .limit(50)
        .get();

    return snap.docs
        .map((d) => ProductModel.fromFirestore(
        d.data() as Map<String, dynamic>, d.id))
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
  // NOTE: addProduct() mein 'nameLower' field bhi save karo
  //       taake searchByName() kaam kare.
  Future<ProductModel> addProduct(ProductModel product) async {
    final data = product.toFirestore();
    data['nameLower'] = product.name.toLowerCase(); // search ke liye
    final ref = await _col.add(data);
    return product.copyWith(id: ref.id);
  }

  // ── Update ─────────────────────────────────────────────────
  Future<void> updateProduct(ProductModel product) {
    final data = product.toFirestore();
    data['nameLower'] = product.name.toLowerCase(); // search ke liye
    return _col.doc(product.id).update(data);
  }

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