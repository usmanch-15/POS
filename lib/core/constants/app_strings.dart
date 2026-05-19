// lib/core/constants/app_strings.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — All UI Strings (easy localization later)
// ─────────────────────────────────────────────────────────────

class AppStrings {
  AppStrings._();

  // ── App ────────────────────────────────────────────────────
  static const String appName        = 'StockPro';
  static const String appTagline     = 'Smart Inventory Management';
  static const String version        = '1.0.0';

  // ── Navigation ─────────────────────────────────────────────
  static const String navDashboard   = 'Dashboard';
  static const String navBilling     = 'Billing';
  static const String navStock       = 'Stock';
  static const String navReports     = 'Reports';
  static const String navSettings    = 'Settings';

  // ── Dashboard ──────────────────────────────────────────────
  static const String todaySales     = "Today's Sales";
  static const String todayProfit    = "Today's Profit";
  static const String totalProducts  = 'Total Products';
  static const String lowStock       = 'Low Stock';
  static const String recentSales    = 'Recent Sales';
  static const String topProducts    = 'Top Products';
  static const String salesOverview  = 'Sales Overview';
  static const String quickActions   = 'Quick Actions';

  // ── Products ───────────────────────────────────────────────
  static const String products       = 'Products';
  static const String addProduct     = 'Add Product';
  static const String editProduct    = 'Edit Product';
  static const String deleteProduct  = 'Delete Product';
  static const String productName    = 'Product Name';
  static const String category       = 'Category';
  static const String salePrice      = 'Sale Price';
  static const String costPrice      = 'Cost Price';
  static const String quantity       = 'Quantity';
  static const String barcode        = 'Barcode';
  static const String inStock        = 'In Stock';
  static const String outOfStock     = 'Out of Stock';
  static const String lowStockAlert  = 'Low Stock Alert';
  static const String searchProducts = 'Search products...';

  // ── Billing / POS ──────────────────────────────────────────
  static const String billing        = 'Billing';
  static const String newBill        = 'New Bill';
  static const String cart           = 'Cart';
  static const String subtotal       = 'Subtotal';
  static const String discount       = 'Discount';
  static const String tax            = 'Tax';
  static const String total          = 'Total';
  static const String payNow         = 'Pay Now';
  static const String cash           = 'Cash';
  static const String card           = 'Card';
  static const String customerName   = 'Customer Name';
  static const String billNumber     = 'Bill #';
  static const String printReceipt   = 'Print Receipt';
  static const String clearCart      = 'Clear Cart';
  static const String addToCart      = 'Add to Cart';
  static const String removeItem     = 'Remove Item';

  // ── Stock ──────────────────────────────────────────────────
  static const String stock          = 'Stock';
  static const String stockAdjust    = 'Adjust Stock';
  static const String stockIn        = 'Stock In';
  static const String stockOut       = 'Stock Out';
  static const String currentStock   = 'Current Stock';
  static const String newStock       = 'New Stock';
  static const String stockHistory   = 'Stock History';
  static const String inventoryValue = 'Inventory Value';

  // ── Reports ────────────────────────────────────────────────
  static const String reports        = 'Reports';
  static const String salesReport    = 'Sales Report';
  static const String profitReport   = 'Profit & Loss';
  static const String dailyReport    = 'Daily Report';
  static const String monthlyReport  = 'Monthly Report';
  static const String exportPdf      = 'Export PDF';
  static const String exportExcel    = 'Export Excel';
  static const String dateRange      = 'Date Range';
  static const String from           = 'From';
  static const String to             = 'To';

  // ── Settings ───────────────────────────────────────────────
  static const String settings       = 'Settings';
  static const String businessInfo   = 'Business Info';
  static const String businessName   = 'Business Name';
  static const String ownerName      = 'Owner Name';
  static const String phone          = 'Phone';
  static const String address        = 'Address';
  static const String gstNumber      = 'GST/NTN Number';
  static const String gstRate        = 'GST Rate (%)';
  static const String currency       = 'Currency';
  static const String darkMode       = 'Dark Mode';
  static const String notifications  = 'Notifications';
  static const String lowStockThreshold = 'Low Stock Threshold';
  static const String saveChanges    = 'Save Changes';
  static const String appearanceSettings = 'Appearance';
  static const String preferenceSettings = 'Preferences';

  // ── Common Actions ─────────────────────────────────────────
  static const String save           = 'Save';
  static const String cancel         = 'Cancel';
  static const String delete         = 'Delete';
  static const String edit           = 'Edit';
  static const String add            = 'Add';
  static const String update         = 'Update';
  static const String confirm        = 'Confirm';
  static const String yes            = 'Yes';
  static const String no             = 'No';
  static const String ok             = 'OK';
  static const String retry          = 'Retry';
  static const String search         = 'Search';
  static const String filter         = 'Filter';
  static const String clear          = 'Clear';
  static const String refresh        = 'Refresh';
  static const String loading        = 'Loading...';
  static const String noData         = 'No data found';
  static const String noProducts     = 'No products found';
  static const String noSales        = 'No sales found';

  // ── Success Messages ───────────────────────────────────────
  static const String productAdded   = 'Product added successfully';
  static const String productUpdated = 'Product updated successfully';
  static const String productDeleted = 'Product deleted successfully';
  static const String saleDone       = 'Sale completed successfully';
  static const String stockUpdated   = 'Stock updated successfully';
  static const String settingsSaved  = 'Settings saved successfully';

  // ── Error Messages ─────────────────────────────────────────
  static const String errorGeneric   = 'Something went wrong. Please try again.';
  static const String errorNetwork   = 'Network error. Check your connection.';
  static const String errorNotFound  = 'Item not found';
  static const String errorRequired  = 'This field is required';
  static const String errorInvalidNum = 'Please enter a valid number';
  static const String errorMinQty    = 'Quantity must be at least 1';
  static const String errorNegPrice  = 'Price cannot be negative';
  static const String errorCartEmpty = 'Cart is empty';

  // ── Confirm Dialogs ────────────────────────────────────────
  static const String confirmDelete  = 'Are you sure you want to delete?';
  static const String confirmClear   = 'Clear the cart? This cannot be undone.';
  static const String confirmSale    = 'Confirm this sale?';
  static const String deleteProductMsg = 'This will permanently delete the product.';

  // ── Empty States ───────────────────────────────────────────
  static const String emptyProducts  = 'No products yet.\nTap + to add your first product.';
  static const String emptySales     = 'No sales recorded today.';
  static const String emptyCart      = 'Cart is empty.\nScan or tap a product to add.';
  static const String emptyStock     = 'No stock alerts.';
  static const String emptyReports   = 'No data available for this period.';
}
