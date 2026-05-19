// lib/providers/auth_provider.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Auth Provider (ChangeNotifier)
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  UserModel?  _user;
  AuthStatus  _status = AuthStatus.loading;
  String?     _error;
  bool        _isLoading = false;

  UserModel?  get user      => _user;
  AuthStatus  get status    => _status;
  String?     get error     => _error;
  bool        get isLoading => _isLoading;
  bool        get isLoggedIn => _status == AuthStatus.authenticated;

  // ── Shortcuts ──────────────────────────────────────────────
  bool get isAdmin   => _user?.role == UserRole.admin;
  bool get isManager => _user?.role == UserRole.manager || isAdmin;
  String get userName => _user?.name ?? '';

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

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
