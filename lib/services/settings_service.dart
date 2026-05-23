// ═══════════════════════════════════════════════════════════════
//  FILE:  lib/services/settings_service.dart   ← YEH FILE NAHI THI
//         Nai file hai — apne project mein banao
//
//  PART 3 — FIX:
//   PEHLE: Settings SharedPreferences mein thi — naye device pe blank
//   AB:    Firestore mein hain — har device pe same settings milti hain
//
//   Kaise use karo:
//     1. Login ke baad AuthProvider mein:
//          await SettingsService.load(businessId);
//     2. Settings save karte waqt:
//          await SettingsService.save(businessId, settings);
//     3. CurrencyProvider (neeche) setting change pe notify karta hai
// ═══════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../services/local_storage_service.dart';
import '../core/utils/currency_formatter.dart';

// ── Settings Model ─────────────────────────────────────────────
class BusinessSettings {
  final String businessName;
  final String ownerName;
  final String phone;
  final String address;
  final String gstNumber;
  final double gstRate;
  final String currency;
  final int    lowStockThreshold;
  final String receiptNote;

  const BusinessSettings({
    this.businessName      = 'My Store',
    this.ownerName         = '',
    this.phone             = '',
    this.address           = '',
    this.gstNumber         = '',
    this.gstRate           = 0.0,
    this.currency          = 'PKR',
    this.lowStockThreshold = 5,
    this.receiptNote       = 'Thank you for your business!',
  });

  factory BusinessSettings.fromMap(Map<String, dynamic> m) =>
      BusinessSettings(
        businessName:      m['businessName']      ?? 'My Store',
        ownerName:         m['ownerName']          ?? '',
        phone:             m['phone']              ?? '',
        address:           m['address']            ?? '',
        gstNumber:         m['gstNumber']          ?? '',
        gstRate:           (m['gstRate']           ?? 0.0).toDouble(),
        currency:          m['currency']           ?? 'PKR',
        lowStockThreshold: m['lowStockThreshold']  ?? 5,
        receiptNote:       m['receiptNote']        ?? 'Thank you for your business!',
      );

  Map<String, dynamic> toMap() => {
    'businessName':      businessName,
    'ownerName':         ownerName,
    'phone':             phone,
    'address':           address,
    'gstNumber':         gstNumber,
    'gstRate':           gstRate,
    'currency':          currency,
    'lowStockThreshold': lowStockThreshold,
    'receiptNote':       receiptNote,
    'updatedAt':         FieldValue.serverTimestamp(),
  };

  BusinessSettings copyWith({
    String? businessName,
    String? ownerName,
    String? phone,
    String? address,
    String? gstNumber,
    double? gstRate,
    String? currency,
    int?    lowStockThreshold,
    String? receiptNote,
  }) =>
      BusinessSettings(
        businessName:      businessName      ?? this.businessName,
        ownerName:         ownerName         ?? this.ownerName,
        phone:             phone             ?? this.phone,
        address:           address           ?? this.address,
        gstNumber:         gstNumber         ?? this.gstNumber,
        gstRate:           gstRate           ?? this.gstRate,
        currency:          currency          ?? this.currency,
        lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
        receiptNote:       receiptNote       ?? this.receiptNote,
      );
}

// ── SettingsService — Firestore single source of truth ─────────
class SettingsService {
  static final _db = FirebaseFirestore.instance;

  // Firestore mein settings document path
  static DocumentReference _ref(String businessId) =>
      _db.collection('settings').doc(businessId);

  // ── Load from Firestore + SharedPreferences fallback ────────
  // Pehli baar agar Firestore mein kuch nahi to SharedPrefs se migrate karo
  static Future<BusinessSettings> load(String businessId) async {
    try {
      final doc = await _ref(businessId).get();
      if (doc.exists && doc.data() != null) {
        return BusinessSettings.fromMap(doc.data() as Map<String, dynamic>);
      }
      // Firestore mein nahi — purani SharedPrefs se migrate karo
      return await _migrateFromSharedPrefs(businessId);
    } catch (e) {
      // Offline fallback — SharedPrefs se lo
      return BusinessSettings(
        businessName:      LocalStorageService.businessName,
        ownerName:         LocalStorageService.ownerName,
        phone:             LocalStorageService.phone,
        address:           LocalStorageService.address,
        gstNumber:         LocalStorageService.gstNumber,
        gstRate:           LocalStorageService.gstRate,
        currency:          LocalStorageService.currency,
        lowStockThreshold: LocalStorageService.lowStockThreshold,
        receiptNote:       LocalStorageService.receiptNote,
      );
    }
  }

  // ── Save to Firestore (primary) + SharedPrefs (offline cache) ─
  static Future<void> save(String businessId, BusinessSettings s) async {
    // Firestore mein save karo (primary)
    await _ref(businessId).set(s.toMap(), SetOptions(merge: true));

    // SharedPrefs mein bhi rakho — offline fallback ke liye
    await LocalStorageService.saveBusinessSettings(
      businessName:      s.businessName,
      ownerName:         s.ownerName,
      phone:             s.phone,
      address:           s.address,
      gstNumber:         s.gstNumber,
      gstRate:           s.gstRate,
      currency:          s.currency,
      lowStockThreshold: s.lowStockThreshold,
      receiptNote:       s.receiptNote,
    );
  }

  // ── Real-time stream — koi bhi device pe change instantly mile ─
  static Stream<BusinessSettings> stream(String businessId) =>
      _ref(businessId).snapshots().map((doc) {
        if (!doc.exists || doc.data() == null) return const BusinessSettings();
        return BusinessSettings.fromMap(doc.data() as Map<String, dynamic>);
      });

  // ── SharedPrefs se Firestore mein migrate karo (ek baar) ───
  static Future<BusinessSettings> _migrateFromSharedPrefs(
      String businessId) async {
    final s = BusinessSettings(
      businessName:      LocalStorageService.businessName,
      ownerName:         LocalStorageService.ownerName,
      phone:             LocalStorageService.phone,
      address:           LocalStorageService.address,
      gstNumber:         LocalStorageService.gstNumber,
      gstRate:           LocalStorageService.gstRate,
      currency:          LocalStorageService.currency,
      lowStockThreshold: LocalStorageService.lowStockThreshold,
      receiptNote:       LocalStorageService.receiptNote,
    );
    // Firestore mein save karo silently
    try {
      await _ref(businessId).set(s.toMap());
    } catch (_) {}
    return s;
  }
}

// ══════════════════════════════════════════════════════════════
//  FILE:  lib/providers/settings_provider.dart  ← YEH FILE NAHI THI
//         Nai file hai — apne project mein banao
//
//  PART 3 — FIX:
//   CurrencyFormatter runtime mein update hota hai ab.
//   Pehle: main.dart mein ek baar setSymbol() — restart chahiye tha
//   Ab:    SettingsProvider notify karta hai — instantly update hota hai
// ══════════════════════════════════════════════════════════════

class SettingsProvider extends ChangeNotifier {
  BusinessSettings _settings = const BusinessSettings();
  bool             _isLoading = false;
  String?          _error;

  BusinessSettings get settings    => _settings;
  bool             get isLoading   => _isLoading;
  String?          get error       => _error;

  // FIX: currency getter — UI seedha yahan se le
  String get currency     => _settings.currency;
  double get gstRate      => _settings.gstRate;
  String get businessName => _settings.businessName;

  // ── Login ke baad call karo ────────────────────────────────
  Future<void> load(String businessId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _settings = await SettingsService.load(businessId);
      // FIX-3B: Runtime currency update — restart ki zaroorat nahi
      CurrencyFormatter.setSymbol(_settings.currency);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  // ── Settings save karo ─────────────────────────────────────
  Future<bool> save(String businessId, BusinessSettings updated) async {
    _isLoading = true;
    notifyListeners();
    try {
      await SettingsService.save(businessId, updated);
      _settings = updated;
      // FIX-3B: Currency turant update ho jati hai — no restart needed
      CurrencyFormatter.setSymbol(updated.currency);
      _error    = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error     = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Logout pe reset ────────────────────────────────────────
  void reset() {
    _settings = const BusinessSettings();
    _error    = null;
    notifyListeners();
  }
}