// lib/providers/auth_provider.dart
// ─────────────────────────────────────────────────────────────
//  PROJECT PATH:  lib/providers/auth_provider.dart
//
//  PART 1 — FIXES:
//   FIX-1B: registerAdmin() invite-only kiya
//           Firestore mein invites/{email} document check hota hai.
//           Agar invite nahi mila — registration block ho jati hai.
//           Successful registration ke baad invite delete hota hai.
//
//   FIX-1A: businessId custom claim set hoti hai login pe
//           (Note: Custom claim Firebase Admin SDK se server side
//            set hoti hai — yahan hum login ke baad reload karte hain
//            taake claim reflect ho)
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
      // FIX-1A: Token force refresh karo taake businessId claim mile
      // Firebase Admin SDK server pe claim set karta hai login ke baad.
      // getIdToken(true) force refresh karta hai — nahi karo to purani
      // claim aati hai jo businessId ke bina hoti hai.
      await firebaseUser.getIdToken(true);

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

  // ── Register Admin — FIX-1B: Invite-Only ──────────────────
  //
  //  PEHLE:
  //    Koi bhi email/password de ke admin ban sakta tha.
  //    Koi check nahi tha.
  //
  //  AB:
  //    Step 1 — Firestore mein invites/{email} document check karo.
  //             Agar nahi mila — registration block.
  //    Step 2 — Firebase Auth mein user banao.
  //    Step 3 — Firestore mein UserModel + businessId save karo.
  //    Step 4 — Settings document banao.
  //    Step 5 — Invite delete karo (ek baar use hota hai).
  //
  //  Invite kaise banao? (Admin Firebase Console se kare ya apna
  //  admin panel banao):
  //    firestore
  //      .collection('invites')
  //      .doc('newuser@example.com')
  //      .set({ 'createdBy': adminUid, 'createdAt': FieldValue.serverTimestamp() })
  //
  Future<bool> registerAdmin({
    required String name,
    required String email,
    required String password,
    required String businessName,
  }) async {
    _setLoading(true);
    _error = null;

    final db           = FirebaseFirestore.instance;
    final normalEmail  = email.trim().toLowerCase();

    try {
      // ── Step 1: Invite check ───────────────────────────────
      final inviteDoc = await db
          .collection('invites')
          .doc(normalEmail)
          .get();

      if (!inviteDoc.exists) {
        _error  = 'Aapke paas valid invite nahi hai. Admin se rabta karein.';
        _status = AuthStatus.unauthenticated;
        _setLoading(false);
        return false;
      }

      // ── Step 2: Firebase Auth mein user banao ─────────────
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email:    normalEmail,
        password: password,
      );
      final uid = cred.user!.uid;

      // ── Step 3: businessId generate karo ──────────────────
      // Har business ki unique ID — sab documents mein yeh field
      // hogi taake multi-tenant isolation kaam kare.
      // Simple approach: business ka apna Firestore doc ID use karo.
      final businessRef = db.collection('businesses').doc();
      final businessId  = businessRef.id;

      // Firestore mein admin UserModel save karo
      final newUser = UserModel(
        id:        uid,
        name:      name.trim(),
        email:     normalEmail,
        role:      UserRole.admin,
        createdAt: DateTime.now(),
      );

      final batch = db.batch();

      // User document
      batch.set(
        db.collection('users').doc(uid),
        {
          ...newUser.toFirestore(),
          'businessId': businessId,   // FIX-1A: businessId har user mein
        },
      );

      // Business document
      batch.set(businessRef, {
        'businessName': businessName.trim(),
        'ownerId':      uid,
        'createdAt':    FieldValue.serverTimestamp(),
      });

      // Settings document
      batch.set(
        db.collection('settings').doc(businessId),
        {
          'businessName': businessName.trim(),
          'ownerId':      uid,
          'businessId':   businessId,
          'createdAt':    FieldValue.serverTimestamp(),
        },
      );

      // ── Step 5: Invite delete karo ────────────────────────
      batch.delete(db.collection('invites').doc(normalEmail));

      await batch.commit();

      // ── NOTE: Custom Claim server se set hogi ─────────────
      // Apne backend (Cloud Function) mein yeh likho:
      //
      //   exports.onUserCreated = functions.auth.user().onCreate(async (user) => {
      //     const userDoc = await admin.firestore()
      //       .collection('users').doc(user.uid).get();
      //     if (userDoc.exists) {
      //       await admin.auth().setCustomUserClaims(user.uid, {
      //         businessId: userDoc.data().businessId,
      //         role: userDoc.data().role,
      //       });
      //     }
      //   });
      //
      // Yeh Cloud Function automatically naye user ke liye
      // businessId claim set kar degi jab user doc create hoga.

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