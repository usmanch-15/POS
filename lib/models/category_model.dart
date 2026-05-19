// lib/models/category_model.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Category Model
// ─────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String? iconName;
  final String? colorHex;
  final int productCount;
  final DateTime createdAt;

  const CategoryModel({
    required this.id,
    required this.name,
    this.iconName,
    this.colorHex,
    this.productCount = 0,
    required this.createdAt,
  });

  // ── Default categories matching existing product.dart ──────
  static const List<String> defaults = [
    'Biscuit',
    'Toffee',
    'Nimko',
    'Chocolate',
    'Paper',
    'Drinks',
    'Dairy',
    'Other',
  ];

  factory CategoryModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return CategoryModel(
      id:           docId,
      name:         data['name']         ?? '',
      iconName:     data['iconName'],
      colorHex:     data['colorHex'],
      productCount: (data['productCount'] ?? 0) as int,
      createdAt:    data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name':         name,
    'iconName':     iconName,
    'colorHex':     colorHex,
    'productCount': productCount,
    'createdAt':    FieldValue.serverTimestamp(),
  };

  CategoryModel copyWith({
    String? id,
    String? name,
    String? iconName,
    String? colorHex,
    int? productCount,
    DateTime? createdAt,
  }) =>
      CategoryModel(
        id:           id           ?? this.id,
        name:         name         ?? this.name,
        iconName:     iconName     ?? this.iconName,
        colorHex:     colorHex     ?? this.colorHex,
        productCount: productCount ?? this.productCount,
        createdAt:    createdAt    ?? this.createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CategoryModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CategoryModel(id: $id, name: $name)';
}
