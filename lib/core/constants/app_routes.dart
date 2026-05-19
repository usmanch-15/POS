// lib/core/constants/app_routes.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Named Route Constants
// ─────────────────────────────────────────────────────────────

class AppRoutes {
  AppRoutes._();

  // ── Auth ───────────────────────────────────────────────────
  static const String login        = '/login';
  static const String splash       = '/splash';

  // ── Main Shell ─────────────────────────────────────────────
  static const String home         = '/';
  static const String dashboard    = '/dashboard';

  // ── Billing / POS ──────────────────────────────────────────
  static const String billing      = '/billing';
  static const String createBill   = '/billing/create';
  static const String billDetail   = '/billing/detail';

  // ── Products ───────────────────────────────────────────────
  static const String products     = '/products';
  static const String addProduct   = '/products/add';
  static const String editProduct  = '/products/edit';
  static const String productDetail = '/products/detail';

  // ── Stock ──────────────────────────────────────────────────
  static const String stock        = '/stock';
  static const String stockAdjust  = '/stock/adjust';

  // ── Sales ──────────────────────────────────────────────────
  static const String sales        = '/sales';
  static const String saleDetail   = '/sales/detail';

  // ── Reports ────────────────────────────────────────────────
  static const String reports      = '/reports';
  static const String dailyReport  = '/reports/daily';
  static const String monthlyReport = '/reports/monthly';
  static const String profitReport = '/reports/profit';

  // ── Settings ───────────────────────────────────────────────
  static const String settings     = '/settings';
  static const String storeSettings = '/settings/store';
  static const String taxSettings  = '/settings/tax';

  // ── Analytics ─────────────────────────────────────────────
  static const String analytics    = '/analytics';
}
