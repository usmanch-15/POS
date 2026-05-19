// lib/models/supplier_model.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Supplier Model
// ─────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';

class SupplierModel {
  final String id;
  final String name;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? address;
  final String? ntn;           // National Tax Number
  final double totalPurchased; // total amount purchased from this supplier
  final int    orderCount;
  final DateTime createdAt;

  const SupplierModel({
    required this.id,
    required this.name,
    this.contactPerson,
    this.phone,
    this.email,
    this.address,
    this.ntn,
    this.totalPurchased = 0,
    this.orderCount     = 0,
    required this.createdAt,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  factory SupplierModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return SupplierModel(
      id:             docId,
      name:           data['name']           ?? '',
      contactPerson:  data['contactPerson'],
      phone:          data['phone'],
      email:          data['email'],
      address:        data['address'],
      ntn:            data['ntn'],
      totalPurchased: (data['totalPurchased'] ?? 0).toDouble(),
      orderCount:     (data['orderCount']     ?? 0) as int,
      createdAt:      data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name':           name,
    'contactPerson':  contactPerson,
    'phone':          phone,
    'email':          email,
    'address':        address,
    'ntn':            ntn,
    'totalPurchased': totalPurchased,
    'orderCount':     orderCount,
    'createdAt':      FieldValue.serverTimestamp(),
  };

  SupplierModel copyWith({
    String? id,
    String? name,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
    String? ntn,
    double? totalPurchased,
    int?    orderCount,
    DateTime? createdAt,
  }) =>
      SupplierModel(
        id:             id             ?? this.id,
        name:           name           ?? this.name,
        contactPerson:  contactPerson  ?? this.contactPerson,
        phone:          phone          ?? this.phone,
        email:          email          ?? this.email,
        address:        address        ?? this.address,
        ntn:            ntn            ?? this.ntn,
        totalPurchased: totalPurchased ?? this.totalPurchased,
        orderCount:     orderCount     ?? this.orderCount,
        createdAt:      createdAt      ?? this.createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SupplierModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
