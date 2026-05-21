// lib/services/sale_service.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Sale / Billing Firestore Service
//  FIXES:
//   1. Bill number race condition → atomic counter document use kiya
//   2. StockMovement previousStock/newStock → transaction mein product
//      ki current qty pehle read karo, phir set karo
// ─────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sale_model.dart';
import '../models/stock_model.dart';

class SaleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _sales   => _db.collection('sales');
  CollectionReference get _stock   => _db.collection('stock_movements');
  CollectionReference get _prods   => _db.collection('products');

  // ── Counter document ref (bill number ke liye) ─────────────
  // FIX #1: Pehle alag query se last bill read karte the — race condition thi.
  //         Ab ek dedicated counter document hai jo transaction ke andar
  //         atomically increment hota hai. Concurrent sales pe duplicate
  //         bill numbers kabhi nahi banen ge.
  DocumentReference get _counter  => _db.collection('meta').doc('bill_counter');

  // ── Stream today's sales ───────────────────────────────────
  Stream<List<SaleModel>> streamTodaySales() {
    final start = DateTime.now();
    final from  = DateTime(start.year, start.month, start.day);
    final to    = DateTime(start.year, start.month, start.day, 23, 59, 59);
    return _sales
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('createdAt', isLessThanOrEqualTo:    Timestamp.fromDate(to))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_mapSales);
  }

  // ── Stream all sales ───────────────────────────────────────
  Stream<List<SaleModel>> streamSales({int limit = 50}) {
    return _sales
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(_mapSales);
  }

  // ── Sales in date range ────────────────────────────────────
  Future<List<SaleModel>> getSalesInRange(DateTime from, DateTime to) async {
    final snap = await _sales
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('createdAt', isLessThanOrEqualTo:    Timestamp.fromDate(to))
        .orderBy('createdAt', descending: true)
        .get();
    return _mapSales(snap);
  }

  // ── Get single sale ────────────────────────────────────────
  Future<SaleModel?> getSale(String id) async {
    final doc = await _sales.doc(id).get();
    if (!doc.exists) return null;
    return SaleModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
  }

  // ── Complete a sale (Firestore transaction) ────────────────
  Future<SaleModel> completeSale(SaleModel sale) async {
    late SaleModel saved;

    await _db.runTransaction((txn) async {
      // ── FIX #1: Atomic bill number ─────────────────────────
      // Counter doc read karo transaction ke andar
      final counterSnap = await txn.get(_counter);
      int nextNum = 1;
      if (counterSnap.exists) {
        nextNum = ((counterSnap.data() as Map<String, dynamic>)['count'] ?? 0) + 1;
      }
      // Counter atomically increment karo
      txn.set(_counter, {'count': nextNum}, SetOptions(merge: true));
      final billNo = 'BILL-${nextNum.toString().padLeft(4, '0')}';

      // ── FIX #2: Stock movements mein sahi previousStock/newStock ──
      // Har product ki current qty transaction mein pehle read karo
      final Map<String, int> previousQtyMap = {};
      for (final item in sale.items) {
        final prodSnap = await txn.get(_prods.doc(item.productId));
        if (prodSnap.exists) {
          previousQtyMap[item.productId] =
              (prodSnap.data() as Map<String, dynamic>)['quantity'] as int? ?? 0;
        }
      }

      // 1. Write sale document
      final saleRef = _sales.doc();
      saved = sale.copyWith(id: saleRef.id, billNumber: billNo);
      txn.set(saleRef, saved.toFirestore());

      // 2. Decrement stock + write accurate movement records
      for (final item in sale.items) {
        final prodRef     = _prods.doc(item.productId);
        final prevStock   = previousQtyMap[item.productId] ?? 0;
        final newStock    = (prevStock - item.quantity).clamp(0, prevStock);

        txn.update(prodRef, {
          'quantity':  FieldValue.increment(-item.quantity),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // FIX #2: Ab previousStock aur newStock sahi values hain
        final movRef = _stock.doc();
        final mov = StockMovement(
          id:            movRef.id,
          productId:     item.productId,
          productName:   item.productName,
          type:          StockMovementType.saleDeduction,
          quantity:      item.quantity,
          previousStock: prevStock,   // ✅ sahi value
          newStock:      newStock,    // ✅ sahi value
          referenceId:   saleRef.id,
          createdAt:     DateTime.now(),
        );
        txn.set(movRef, mov.toFirestore());
      }
    });

    return saved;
  }

  // ── Refund a sale ──────────────────────────────────────────
  Future<void> refundSale(String saleId) async {
    final sale = await getSale(saleId);
    if (sale == null) return;

    await _db.runTransaction((txn) async {
      txn.update(_sales.doc(saleId), {'status': SaleStatus.refunded.name});

      for (final item in sale.items) {
        final prodRef  = _prods.doc(item.productId);
        final prodSnap = await txn.get(prodRef);
        final prevQty  = prodSnap.exists
            ? (prodSnap.data() as Map<String, dynamic>)['quantity'] as int? ?? 0
            : 0;
        final newQty   = prevQty + item.quantity;

        txn.update(prodRef, {
          'quantity':  FieldValue.increment(item.quantity),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Refund movement bhi record karo
        final movRef = _stock.doc();
        final mov = StockMovement(
          id:            movRef.id,
          productId:     item.productId,
          productName:   item.productName,
          type:          StockMovementType.returnIn,
          quantity:      item.quantity,
          previousStock: prevQty,
          newStock:      newQty,
          referenceId:   saleId,
          reason:        'Sale refund',
          createdAt:     DateTime.now(),
        );
        txn.set(movRef, mov.toFirestore());
      }
    });
  }

  // ── Helper ─────────────────────────────────────────────────
  List<SaleModel> _mapSales(QuerySnapshot snap) => snap.docs
      .map((d) => SaleModel.fromFirestore(d.data() as Map<String, dynamic>, d.id))
      .toList();
}