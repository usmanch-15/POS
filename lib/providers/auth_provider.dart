// lib/providers/auth_provider.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Auth Provider (ChangeNotifier)
//  FIX: registerAdmin() method add kiya signup screen ke liye
// ─────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  UserModel?  _user;
  AuthStatus  _status    = AuthStatus.loading;
  String?     _error;
  bool        _isLoading = false;

  UserModel?  get user       => _user;
  AuthStatus  get status     => _status;
  String?     get error      => _error;
  bool        get isLoading  => _isLoading;
  bool        get isLoggedIn => _status == AuthStatus.authenticated;

  bool   get isAdmin   => _user?.role == UserRole.admin;
  bool   get isManager => _user?.role == UserRole.manager || isAdmin;
  String get userName  => _user?.name ?? '';

  AuthProvider() {
    _service.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user   = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    try {
      _user   = await _service.getUserModel(firebaseUser.uid);
      _status = _user != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
      _error  = null;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _error  = e.toString();
    }
    notifyListeners();
  }

  // ── Login ──────────────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      _user   = await _service.login(email, password);
      _status = AuthStatus.authenticated;
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _error  = AuthService.errorMessage(e.code);
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      return false;
    } catch (e) {
      _error  = e.toString();
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      return false;
    }
  }

  // ── Logout ─────────────────────────────────────────────────
  Future<void> logout() async {
    await _service.logout();
    _user   = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // ── Create staff (admin only) ──────────────────────────────
  Future<bool> createStaff({
    required String   name,
    required String   email,
    required String   password,
    required UserRole role,
  }) async {
    if (!isAdmin) return false;
    _setLoading(true);
    try {
      await _service.createStaffAccount(
          name: name, email: email, password: password, role: role);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = AuthService.errorMessage(e.code);
      _setLoading(false);
      return false;
    }
  }

  // ── Register Admin — signup screen ke liye ─────────────────
  // Naya business owner pehli baar account banata hai.
  // UserModel mein businessName field nahi hai isliye
  // businessName sirf settings document mein save hota hai.
  Future<bool> registerAdmin({
    required String name,
    required String email,
    required String password,
    required String businessName,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      // 1. Firebase Auth mein user banao
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email:    email.trim(),
        password: password,
      );

      // 2. Firestore mein admin UserModel save karo
      final newUser = UserModel(
        id:        cred.user!.uid,
        name:      name.trim(),
        email:     email.trim(),
        role:      UserRole.admin,
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(newUser.id)
          .set(newUser.toFirestore());

      // 3. Business settings document save karo
      await FirebaseFirestore.instance
          .collection('settings')
          .doc('business')
          .set({
        'businessName': businessName.trim(),
        'ownerId':      cred.user!.uid,
        'createdAt':    FieldValue.serverTimestamp(),
      });

      _user   = newUser;
      _status = AuthStatus.authenticated;
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _error  = AuthService.errorMessage(e.code);
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      return false;
    } catch (e) {
      _error  = e.toString();
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      return false;
    }
  }

  // ── Helpers ────────────────────────────────────────────────
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}