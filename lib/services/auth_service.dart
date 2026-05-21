// lib/services/auth_service.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Firebase Auth Service
//  FIX: createStaffAccount() mein admin logout ho jata tha.
//       Reason: createUserWithEmailAndPassword() automatically
//       naye user ko sign-in kar deta hai, admin ko log out.
//       Solution: Secondary Firebase App instance use karo
//       sirf staff creation ke liye. Admin session safe rehti hai.
// ─────────────────────────────────────────────────────────────

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../firebase_options.dart';

class AuthService {
  final FirebaseAuth      _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db   = FirebaseFirestore.instance;

  // ── Secondary app naam — staff creation ke liye ────────────
  static const String _secondaryAppName = 'staff_creator';

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
  // FIX: Secondary Firebase App use karo taake admin ka session
  //      disturb na ho. Naya user create hota hai secondary app
  //      mein, phir us app ko delete kar dete hain.
  Future<UserModel> createStaffAccount({
    required String   name,
    required String   email,
    required String   password,
    required UserRole role,
  }) async {
    // Secondary app already exist karti hai to use karo, warna banao
    FirebaseApp secondaryApp;
    try {
      secondaryApp = Firebase.app(_secondaryAppName);
    } on FirebaseException {
      secondaryApp = await Firebase.initializeApp(
        name:    _secondaryAppName,
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    try {
      // Secondary app ki auth instance se staff banao
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      final cred = await secondaryAuth.createUserWithEmailAndPassword(
        email:    email.trim(),
        password: password,
      );

      // Firestore mein user document save karo (main db instance se)
      final user = UserModel(
        id:        cred.user!.uid,
        name:      name,
        email:     email,
        role:      role,
        createdAt: DateTime.now(),
      );
      await _db.collection('users').doc(user.id).set(user.toFirestore());

      // Secondary app ki session band karo — admin safe hai
      await secondaryAuth.signOut();

      return user;
    } finally {
      // Secondary app ko cleanup karo
      try {
        await secondaryApp.delete();
      } catch (_) {}
    }
  }

  // ── Update password ────────────────────────────────────────
  Future<void> updatePassword(String newPassword) =>
      _auth.currentUser!.updatePassword(newPassword);

  // ── Reset password email ───────────────────────────────────
  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  // ── Friendly error messages (Urdu/English) ────────────────
  static String errorMessage(String code) {
    switch (code) {
      case 'user-not-found':       return 'Email registered nahi hai';
      case 'wrong-password':       return 'Password galat hai';
      case 'invalid-email':        return 'Email sahi format mein likhein';
      case 'user-disabled':        return 'Yeh account disable kar diya gaya hai';
      case 'email-already-in-use': return 'Email pehle se registered hai';
      case 'weak-password':        return 'Password zyada strong chahiye (min 6 chars)';
      case 'too-many-requests':    return 'Zyada attempts — thodi der baad try karein';
      case 'invalid-credential':   return 'Email ya password galat hai';
      default:                     return 'Login mein masla aaya: $code';
    }
  }
}