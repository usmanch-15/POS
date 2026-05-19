// lib/models/user_model.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — User / Staff Model
// ─────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, manager, cashier }

extension UserRoleExt on UserRole {
  String get label {
    switch (this) {
      case UserRole.admin:    return 'Admin';
      case UserRole.manager:  return 'Manager';
      case UserRole.cashier:  return 'Cashier';
    }
  }

  bool get canManageProducts => this == UserRole.admin || this == UserRole.manager;
  bool get canViewReports    => this == UserRole.admin || this == UserRole.manager;
  bool get canManageUsers    => this == UserRole.admin;
  bool get canDeleteSales    => this == UserRole.admin;
}

class UserModel {
  final String   id;
  final String   name;
  final String   email;
  final UserRole role;
  final bool     isActive;
  final String?  phone;
  final DateTime createdAt;
  final DateTime? lastLogin;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isActive  = true,
    this.phone,
    required this.createdAt,
    this.lastLogin,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  static UserRole _roleFromString(String? s) {
    switch (s) {
      case 'admin':   return UserRole.admin;
      case 'manager': return UserRole.manager;
      default:        return UserRole.cashier;
    }
  }

  factory UserModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return UserModel(
      id:        docId,
      name:      data['name']     ?? '',
      email:     data['email']    ?? '',
      role:      _roleFromString(data['role']),
      isActive:  data['isActive'] ?? true,
      phone:     data['phone'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      lastLogin: data['lastLogin'] != null
          ? (data['lastLogin'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name':      name,
    'email':     email,
    'role':      role.name,
    'isActive':  isActive,
    'phone':     phone,
    'createdAt': FieldValue.serverTimestamp(),
    'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
  };

  UserModel copyWith({
    String?    id,
    String?    name,
    String?    email,
    UserRole?  role,
    bool?      isActive,
    String?    phone,
    DateTime?  createdAt,
    DateTime?  lastLogin,
  }) =>
      UserModel(
        id:        id        ?? this.id,
        name:      name      ?? this.name,
        email:     email     ?? this.email,
        role:      role      ?? this.role,
        isActive:  isActive  ?? this.isActive,
        phone:     phone     ?? this.phone,
        createdAt: createdAt ?? this.createdAt,
        lastLogin: lastLogin ?? this.lastLogin,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UserModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
