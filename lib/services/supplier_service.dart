// lib/services/supplier_service.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Supplier Firestore Service
// ─────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/supplier_model.dart';

class SupplierService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference get _col => _db.collection('suppliers');

  // ── Stream ─────────────────────────────────────────────────
  Stream<List<SupplierModel>> streamSuppliers() {
    return _col.orderBy('name').snapshots().map((snap) => snap.docs
        .map((d) => SupplierModel.fromFirestore(
              d.data() as Map<String, dynamic>, d.id))
        .toList());
  }

  // ── Get all ────────────────────────────────────────────────
  Future<List<SupplierModel>> getSuppliers() async {
    final snap = await _col.orderBy('name').get();
    return snap.docs
        .map((d) => SupplierModel.fromFirestore(
              d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  // ── Get single ─────────────────────────────────────────────
  Future<SupplierModel?> getSupplier(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return SupplierModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
  }

  // ── Search ─────────────────────────────────────────────────
  Future<List<SupplierModel>> search(String query) async {
    final lower = query.toLowerCase();
    final snap  = await _col.get();
    return snap.docs
        .map((d) => SupplierModel.fromFirestore(
              d.data() as Map<String, dynamic>, d.id))
        .where((s) =>
            s.name.toLowerCase().contains(lower) ||
            (s.phone?.contains(lower) ?? false))
        .toList();
  }

  // ── Add ────────────────────────────────────────────────────
  Future<SupplierModel> addSupplier(SupplierModel supplier) async {
    final ref = await _col.add(supplier.toFirestore());
    return supplier.copyWith(id: ref.id);
  }

  // ── Update ─────────────────────────────────────────────────
  Future<void> updateSupplier(SupplierModel supplier) =>
      _col.doc(supplier.id).update(supplier.toFirestore());

  // ── Delete ─────────────────────────────────────────────────
  Future<void> deleteSupplier(String id) => _col.doc(id).delete();

  // ── Update totals after purchase ──────────────────────────
  Future<void> recordPurchase(String supplierId, double amount) =>
      _col.doc(supplierId).update({
        'totalPurchased': FieldValue.increment(amount),
        'orderCount':     FieldValue.increment(1),
      });
}
