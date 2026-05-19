// lib/services/customer_service.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Customer Firestore Service
// ─────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';

class CustomerService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference get _col => _db.collection('customers');

  // ── Stream all customers ───────────────────────────────────
  Stream<List<CustomerModel>> streamCustomers() {
    return _col
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => CustomerModel.fromFirestore(
                  d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  // ── Get all ────────────────────────────────────────────────
  Future<List<CustomerModel>> getCustomers() async {
    final snap = await _col.orderBy('name').get();
    return snap.docs
        .map((d) => CustomerModel.fromFirestore(
              d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  // ── Get single ─────────────────────────────────────────────
  Future<CustomerModel?> getCustomer(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return CustomerModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
  }

  // ── Search by name or phone ────────────────────────────────
  Future<List<CustomerModel>> search(String query) async {
    final lower = query.toLowerCase();
    final snap  = await _col.get();
    return snap.docs
        .map((d) => CustomerModel.fromFirestore(
              d.data() as Map<String, dynamic>, d.id))
        .where((c) =>
            c.name.toLowerCase().contains(lower) ||
            (c.phone?.contains(lower) ?? false))
        .toList();
  }

  // ── Add ────────────────────────────────────────────────────
  Future<CustomerModel> addCustomer(CustomerModel customer) async {
    final ref = await _col.add(customer.toFirestore());
    return customer.copyWith(id: ref.id);
  }

  // ── Update ─────────────────────────────────────────────────
  Future<void> updateCustomer(CustomerModel customer) =>
      _col.doc(customer.id).update(customer.toFirestore());

  // ── Delete ─────────────────────────────────────────────────
  Future<void> deleteCustomer(String id) => _col.doc(id).delete();

  // ── Update totals after sale ───────────────────────────────
  Future<void> recordPurchase(String customerId, double amount) =>
      _col.doc(customerId).update({
        'totalPurchases': FieldValue.increment(amount),
        'visitCount':     FieldValue.increment(1),
        'lastVisit':      FieldValue.serverTimestamp(),
      });

  // ── Add loyalty points ─────────────────────────────────────
  Future<void> addLoyaltyPoints(String customerId, double points) =>
      _col.doc(customerId).update({
        'loyaltyPoints': FieldValue.increment(points),
      });
}
