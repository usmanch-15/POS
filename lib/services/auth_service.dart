// lib/services/auth_service.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Firebase Auth Service
// ─────────────────────────────────────────────────────────────

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth      _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db   = FirebaseFirestore.instance;

  // ── Current user stream ────────────────────────────────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User?         get currentFirebaseUser => _auth.currentUser;

  // ── Login ──────────────────────────────────────────────────
  Future<UserModel?> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email:    email.trim(),
      password: password,
    );
    return _fetchUserModel(cred.user!.uid);
  }

  // ── Logout ─────────────────────────────────────────────────
  Future<void> logout() => _auth.signOut();

  // ── Fetch UserModel from Firestore ─────────────────────────
  Future<UserModel?> _fetchUserModel(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc.data()!, doc.id);
  }

  Future<UserModel?> getUserModel(String uid) => _fetchUserModel(uid);

  // ── Create staff account (admin only) ─────────────────────
  Future<UserModel> createStaffAccount({
    required String   name,
    required String   email,
    required String   password,
    required UserRole role,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email:    email.trim(),
      password: password,
    );
    final user = UserModel(
      id:        cred.user!.uid,
      name:      name,
      email:     email,
      role:      role,
      createdAt: DateTime.now(),
    );
    await _db.collection('users').doc(user.id).set(user.toFirestore());
    return user;
  }

  // ── Update password ────────────────────────────────────────
  Future<void> updatePassword(String newPassword) =>
      _auth.currentUser!.updatePassword(newPassword);

  // ── Reset password email ───────────────────────────────────
  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  // ── Friendly error message ─────────────────────────────────
  static String errorMessage(String code) {
    switch (code) {
      case 'user-not-found':      return 'Email registered nahi hai';
      case 'wrong-password':      return 'Password galat hai';
      case 'invalid-email':       return 'Email sahi format mein likhein';
      case 'user-disabled':       return 'Yeh account disable kar diya gaya hai';
      case 'email-already-in-use':return 'Email pehle se registered hai';
      case 'weak-password':       return 'Password zyada strong chahiye (min 6 chars)';
      case 'too-many-requests':   return 'Zyada attempts — thodi der baad try karein';
      default:                    return 'Login mein masla aaya: $code';
    }
  }
}
