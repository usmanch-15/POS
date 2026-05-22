// lib/models/stock_model.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Stock Adjustment / Movement Model
// ─────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';

// FIX: returnIn case add kiya — sale_service.dart mein refund ke
//      liye yeh type use hota hai. Pehle sirf 'returned' tha.
enum StockMovementType { stockIn, stockOut, adjustment, saleDeduction, returned, returnIn }

extension StockMovementTypeExt on StockMovementType {
  // FIX: if-case syntax hata ke proper switch expression use kiya.
  //      Saare 6 cases cover hain — ab null return nahi hoga.
  String get label => switch (this) {
    StockMovementType.stockIn       => 'Stock In',
    StockMovementType.stockOut      => 'Stock Out',
    StockMovementType.adjustment    => 'Adjustment',
    StockMovementType.saleDeduction => 'Sale',
    StockMovementType.returned      => 'Returned',
    StockMovementType.returnIn      => 'Return In',   // ← FIX: missing case
  };

  bool get isPositive =>
      this == StockMovementType.stockIn   ||
          this == StockMovementType.returned  ||
          this == StockMovementType.returnIn; // ← FIX: return in bhi positive hai
}

class StockMovement {
  final String            id;
  final String            productId;
  final String            productName;
  final StockMovementType type;
  final int               quantity;        // always positive
  final int               previousStock;
  final int               newStock;
  final String?           reason;
  final String?           addedBy;
  final String?           referenceId;     // saleId or purchaseId
  final DateTime          createdAt;

  const StockMovement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.previousStock,
    required this.newStock,
    this.reason,
    this.addedBy,
    this.referenceId,
    required this.createdAt,
  });

  // Signed quantity for display: +10 or -5
  int get signedQuantity =>
      type.isPositive ? quantity : -quantity;

  static StockMovementType _typeFrom(String? s) {
    return StockMovementType.values.firstWhere(
          (e) => e.name == s,
      orElse: () => StockMovementType.adjustment,
    );
  }

  factory StockMovement.fromFirestore(Map<String, dynamic> data, String docId) {
    return StockMovement(
      id:            docId,
      productId:     data['productId']     ?? '',
      productName:   data['productName']   ?? '',
      type:          _typeFrom(data['type']),
      quantity:      (data['quantity']      ?? 0) as int,
      previousStock: (data['previousStock'] ?? 0) as int,
      newStock:      (data['newStock']      ?? 0) as int,
      reason:        data['reason'],
      addedBy:       data['addedBy'],
      referenceId:   data['referenceId'],
      createdAt:     data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'productId':     productId,
    'productName':   productName,
    'type':          type.name,
    'quantity':      quantity,
    'previousStock': previousStock,
    'newStock':      newStock,
    'reason':        reason,
    'addedBy':       addedBy,
    'referenceId':   referenceId,
    'createdAt':     FieldValue.serverTimestamp(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is StockMovement && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Summary model used by inventory screen
class StockSummary {
  final int totalProducts;
  final int inStockCount;
  final int lowStockCount;
  final int outOfStockCount;
  final double totalValue;

  const StockSummary({
    required this.totalProducts,
    required this.inStockCount,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.totalValue,
  });
}