// lib/models/product_model.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Product Model
//  (extends / replaces the minimal lib/models/product.dart stub)
// ─────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';

enum StockStatus { inStock, lowStock, outOfStock }

extension StockStatusExt on StockStatus {
  String get label {
    switch (this) {
      case StockStatus.inStock:    return 'In Stock';
      case StockStatus.lowStock:   return 'Low Stock';
      case StockStatus.outOfStock: return 'Out of Stock';
    }
  }

  String get key {
    switch (this) {
      case StockStatus.inStock:    return 'in_stock';
      case StockStatus.lowStock:   return 'low_stock';
      case StockStatus.outOfStock: return 'out_of_stock';
    }
  }
}

class ProductModel {
  final String  id;
  final String  name;
  final String  category;
  final String? barcode;
  final double  salePrice;
  final double  costPrice;
  final int     quantity;
  final int     minStockLevel;   // threshold for low-stock alert
  final String? imageUrl;
  final String? description;
  final bool    isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ProductModel({
    required this.id,
    required this.name,
    required this.category,
    this.barcode,
    required this.salePrice,
    required this.costPrice,
    required this.quantity,
    this.minStockLevel = 5,
    this.imageUrl,
    this.description,
    this.isActive  = true,
    required this.createdAt,
    this.updatedAt,
  });

  // ── Computed ───────────────────────────────────────────────
  double get profit        => salePrice - costPrice;
  double get profitMargin  => salePrice > 0 ? (profit / salePrice) * 100 : 0;
  double get inventoryValue => costPrice * quantity;

  StockStatus get stockStatus {
    if (quantity <= 0)              return StockStatus.outOfStock;
    if (quantity <= minStockLevel)  return StockStatus.lowStock;
    return StockStatus.inStock;
  }

  bool get isLowStock    => stockStatus == StockStatus.lowStock;
  bool get isOutOfStock  => stockStatus == StockStatus.outOfStock;

  // ── Firestore ──────────────────────────────────────────────
  factory ProductModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return ProductModel(
      id:            docId,
      name:          data['name']          ?? '',
      category:      data['category']      ?? 'Other',
      barcode:       data['barcode'],
      salePrice:     (data['salePrice']    ?? data['price'] ?? 0).toDouble(),
      costPrice:     (data['costPrice']    ?? data['cost']  ?? 0).toDouble(),
      quantity:      (data['quantity']     ?? data['stock'] ?? 0) as int,
      minStockLevel: (data['minStockLevel'] ?? 5) as int,
      imageUrl:      data['imageUrl'],
      description:   data['description'],
      isActive:      data['isActive']      ?? true,
      createdAt:     data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt:     data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name':          name,
    'category':      category,
    'barcode':       barcode,
    'salePrice':     salePrice,
    'costPrice':     costPrice,
    'quantity':      quantity,
    'minStockLevel': minStockLevel,
    'imageUrl':      imageUrl,
    'description':   description,
    'isActive':      isActive,
    'createdAt':     FieldValue.serverTimestamp(),
    'updatedAt':     FieldValue.serverTimestamp(),
  };

  ProductModel copyWith({
    String?   id,
    String?   name,
    String?   category,
    String?   barcode,
    double?   salePrice,
    double?   costPrice,
    int?      quantity,
    int?      minStockLevel,
    String?   imageUrl,
    String?   description,
    bool?     isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      ProductModel(
        id:            id            ?? this.id,
        name:          name          ?? this.name,
        category:      category      ?? this.category,
        barcode:       barcode       ?? this.barcode,
        salePrice:     salePrice     ?? this.salePrice,
        costPrice:     costPrice     ?? this.costPrice,
        quantity:      quantity      ?? this.quantity,
        minStockLevel: minStockLevel ?? this.minStockLevel,
        imageUrl:      imageUrl      ?? this.imageUrl,
        description:   description   ?? this.description,
        isActive:      isActive      ?? this.isActive,
        createdAt:     createdAt     ?? this.createdAt,
        updatedAt:     updatedAt     ?? this.updatedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ProductModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ProductModel($name, qty: $quantity, price: $salePrice)';
}
