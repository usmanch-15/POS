// lib/services/purchase_service.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Purchase / Stock-In Order Service
// ─────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/purchase_model.dart';
import '../models/stock_model.dart';

class PurchaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _purchases  => _db.collection('purchases');
  CollectionReference get _products   => _db.collection('products');
  CollectionReference get _movements  => _db.collection('stock_movements');

  // ── Stream ─────────────────────────────────────────────────
  Stream<List<PurchaseModel>> streamPurchases({int limit = 50}) {
    return _purchases
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => PurchaseModel.fromFirestore(
                  d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  // ── Add purchase (does NOT add stock yet) ─────────────────
  Future<PurchaseModel> addPurchase(PurchaseModel purchase) async {
    final ref = await _purchases.add(purchase.toFirestore());
    return purchase.copyWith(id: ref.id);
  }

  // ── Mark as received + update stock ───────────────────────
  Future<void> markReceived({
    required PurchaseModel purchase,
    required String        receivedBy,
  }) async {
    await _db.runTransaction((txn) async {
      // Update purchase status
      txn.update(_purchases.doc(purchase.id), {
        'status':     PurchaseStatus.received.name,
        'receivedAt': FieldValue.serverTimestamp(),
      });

      // Update stock for each item
      for (final item in purchase.items) {
        txn.update(_products.doc(item.productId), {
          'quantity':  FieldValue.increment(item.quantity),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Write stock movement
        final movRef = _movements.doc();
        final mov = StockMovement(
          id:            movRef.id,
          productId:     item.productId,
          productName:   item.productName,
          type:          StockMovementType.stockIn,
          quantity:      item.quantity,
          previousStock: 0,
          newStock:      0,
          addedBy:       receivedBy,
          referenceId:   purchase.id,
          createdAt:     DateTime.now(),
        );
        txn.set(movRef, mov.toFirestore());
      }
    });
  }

  // ── Cancel purchase ────────────────────────────────────────
  Future<void> cancelPurchase(String id) =>
      _purchases.doc(id).update({'status': PurchaseStatus.cancelled.name});

  // ── Delete ─────────────────────────────────────────────────
  Future<void> deletePurchase(String id) => _purchases.doc(id).delete();

  // ── Get single ─────────────────────────────────────────────
  Future<PurchaseModel?> getPurchase(String id) async {
    final doc = await _purchases.doc(id).get();
    if (!doc.exists) return null;
    return PurchaseModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
  }
}
