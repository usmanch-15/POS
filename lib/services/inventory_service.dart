import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/stock_model.dart';
import '../services/product_service.dart'; // ✅ FIX: import add kiya

class InventoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _prods     => _db.collection('products');
  CollectionReference get _movements => _db.collection('stock_movements');

  // ── Stream all stock movements ─────────────────────────────
  Stream<List<StockMovement>> streamMovements({int limit = 100}) {
    return _movements
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => StockMovement.fromFirestore(
        d.data() as Map<String, dynamic>, d.id))
        .toList());
  }

  // ── Movements for one product ──────────────────────────────
  Stream<List<StockMovement>> streamProductMovements(String productId) {
    return _movements
        .where('productId', isEqualTo: productId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => StockMovement.fromFirestore(
        d.data() as Map<String, dynamic>, d.id))
        .toList());
  }

  // ── Low stock products stream ──────────────────────────────
  Stream<List<ProductModel>> streamLowStockProducts() {
    return _prods
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => ProductModel.fromFirestore(
        d.data() as Map<String, dynamic>, d.id))
        .where((p) => p.isLowStock || p.isOutOfStock)
        .toList());
  }

  // ── Adjust stock (manual: add or remove) ──────────────────
  Future<void> adjustStock({
    required ProductModel      product,
    required int               newQuantity,
    required String            reason,
    required String            addedBy,
    required StockMovementType type,
  }) async {
    final diff = newQuantity - product.quantity;
    if (diff == 0) return;

    await _db.runTransaction((txn) async {
      txn.update(_prods.doc(product.id), {
        'quantity':  newQuantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final movRef = _movements.doc();
      final mov = StockMovement(
        id:            movRef.id,
        productId:     product.id,
        productName:   product.name,
        type:          type,
        quantity:      diff.abs(),
        previousStock: product.quantity,
        newStock:      newQuantity,
        reason:        reason,
        addedBy:       addedBy,
        createdAt:     DateTime.now(),
        businessId:    ProductService.cachedBusinessId, // ✅ FIX: line 72
      );
      txn.set(movRef, mov.toFirestore());
    });
  }

  // ── Stock In (from purchase) ───────────────────────────────
  Future<void> stockIn({
    required String productId,
    required String productName,
    required int    currentQty,
    required int    addedQty,
    required String addedBy,
    String?         referenceId,
  }) async {
    final newQty = currentQty + addedQty;
    await _db.runTransaction((txn) async {
      txn.update(_prods.doc(productId), {
        'quantity':  newQty,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final movRef = _movements.doc();
      final mov = StockMovement(
        id:            movRef.id,
        productId:     productId,
        productName:   productName,
        type:          StockMovementType.stockIn,
        quantity:      addedQty,
        previousStock: currentQty,
        newStock:      newQty,
        addedBy:       addedBy,
        referenceId:   referenceId,
        createdAt:     DateTime.now(),
        businessId:    ProductService.cachedBusinessId, // ✅ FIX: line 104
      );
      txn.set(movRef, mov.toFirestore());
    });
  }

  // ── Get stock summary ──────────────────────────────────────
  Future<StockSummary> getStockSummary() async {
    final snap = await _prods.where('isActive', isEqualTo: true).get();
    final products = snap.docs
        .map((d) => ProductModel.fromFirestore(
        d.data() as Map<String, dynamic>, d.id))
        .toList();

    return StockSummary(
      totalProducts:   products.length,
      inStockCount:    products
          .where((p) => p.stockStatus == StockStatus.inStock).length,
      lowStockCount:   products.where((p) => p.isLowStock).length,
      outOfStockCount: products.where((p) => p.isOutOfStock).length,
      totalValue:      products.fold(0.0, (s, p) => s + p.inventoryValue),
    );
  }
}