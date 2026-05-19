// lib/services/local_storage_service.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — SharedPreferences Local Storage Service
// ─────────────────────────────────────────────────────────────

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static late SharedPreferences _prefs;

  // ── Initialize (call once in main.dart) ───────────────────
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Keys ───────────────────────────────────────────────────
  static const String _keyBusinessName  = 'business_name';
  static const String _keyOwnerName     = 'owner_name';
  static const String _keyPhone         = 'phone';
  static const String _keyAddress       = 'address';
  static const String _keyGstNumber     = 'gst_number';
  static const String _keyGstRate       = 'gst_rate';
  static const String _keyCurrency      = 'currency';
  static const String _keyDarkMode      = 'dark_mode';
  static const String _keyLowStockAlert = 'low_stock_threshold';
  static const String _keyReceiptNote   = 'receipt_note';
  static const String _keyLastBillNo    = 'last_bill_no';

  // ── Business Settings ──────────────────────────────────────
  static String get businessName   => _prefs.getString(_keyBusinessName)  ?? 'My Store';
  static String get ownerName      => _prefs.getString(_keyOwnerName)     ?? '';
  static String get phone          => _prefs.getString(_keyPhone)         ?? '';
  static String get address        => _prefs.getString(_keyAddress)       ?? '';
  static String get gstNumber      => _prefs.getString(_keyGstNumber)     ?? '';
  static double get gstRate        => _prefs.getDouble(_keyGstRate)       ?? 0.0;
  static String get currency       => _prefs.getString(_keyCurrency)      ?? 'PKR';
  static bool   get isDarkMode     => _prefs.getBool(_keyDarkMode)        ?? true;
  static int    get lowStockThreshold => _prefs.getInt(_keyLowStockAlert) ?? 5;
  static String get receiptNote    => _prefs.getString(_keyReceiptNote)   ?? 'Thank you for your business!';
  static int    get lastBillNo     => _prefs.getInt(_keyLastBillNo)       ?? 0;

  // ── Setters ────────────────────────────────────────────────
  static Future<void> setBusinessName(String v)    => _prefs.setString(_keyBusinessName, v);
  static Future<void> setOwnerName(String v)       => _prefs.setString(_keyOwnerName, v);
  static Future<void> setPhone(String v)           => _prefs.setString(_keyPhone, v);
  static Future<void> setAddress(String v)         => _prefs.setString(_keyAddress, v);
  static Future<void> setGstNumber(String v)       => _prefs.setString(_keyGstNumber, v);
  static Future<void> setGstRate(double v)         => _prefs.setDouble(_keyGstRate, v);
  static Future<void> setCurrency(String v)        => _prefs.setString(_keyCurrency, v);
  static Future<void> setDarkMode(bool v)          => _prefs.setBool(_keyDarkMode, v);
  static Future<void> setLowStockThreshold(int v)  => _prefs.setInt(_keyLowStockAlert, v);
  static Future<void> setReceiptNote(String v)     => _prefs.setString(_keyReceiptNote, v);
  static Future<void> setLastBillNo(int v)         => _prefs.setInt(_keyLastBillNo, v);

  // ── Save all settings at once ──────────────────────────────
  static Future<void> saveBusinessSettings({
    required String businessName,
    required String ownerName,
    required String phone,
    required String address,
    required String gstNumber,
    required double gstRate,
    required String currency,
    required int    lowStockThreshold,
    required String receiptNote,
  }) async {
    await Future.wait([
      setBusinessName(businessName),
      setOwnerName(ownerName),
      setPhone(phone),
      setAddress(address),
      setGstNumber(gstNumber),
      setGstRate(gstRate),
      setCurrency(currency),
      setLowStockThreshold(lowStockThreshold),
      setReceiptNote(receiptNote),
    ]);
  }

  // ── Clear all (for logout) ─────────────────────────────────
  static Future<void> clear() => _prefs.clear();
}
