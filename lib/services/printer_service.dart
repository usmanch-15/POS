// lib/services/printer_service.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Receipt Printer Service
//  Supports: print to screen (share PDF) + thermal printer stub
// ─────────────────────────────────────────────────────────────

import '../models/sale_model.dart';
import 'local_storage_service.dart';
import '../core/utils/currency_formatter.dart';
import '../core/utils/date_formatter.dart';

class PrinterService {
  // ── Generate receipt as plain text ────────────────────────
  static String generateReceiptText(SaleModel sale) {
    final biz    = LocalStorageService.businessName;
    final addr   = LocalStorageService.address;
    final phone  = LocalStorageService.phone;
    final note   = LocalStorageService.receiptNote;
    final line   = '─' * 32;
    final buf    = StringBuffer();

    buf.writeln(biz.toUpperCase().padLeft((32 + biz.length) ~/ 2));
    if (addr.isNotEmpty)  buf.writeln(addr.padLeft((32 + addr.length) ~/ 2));
    if (phone.isNotEmpty) buf.writeln(phone.padLeft((32 + phone.length) ~/ 2));
    buf.writeln(line);
    buf.writeln('Bill: ${sale.billNumber}');
    buf.writeln('Date: ${DateFormatter.dateTime(sale.createdAt)}');
    if (sale.customerName != null)
      buf.writeln('Customer: ${sale.customerName}');
    buf.writeln(line);

    // Items
    for (final item in sale.items) {
      final name  = item.productName.length > 18
          ? item.productName.substring(0, 18)
          : item.productName;
      final price = CurrencyFormatter.formatNumber(item.total);
      buf.writeln('${name.padRight(22)}${price.padLeft(10)}');
      buf.writeln('  ${item.quantity} x ${CurrencyFormatter.formatNumber(item.salePrice)}');
    }

    buf.writeln(line);
    buf.writeln('Subtotal: ${CurrencyFormatter.format(sale.subtotal).padLeft(22)}');
    if (sale.discountAmount > 0)
      buf.writeln('Discount: ${CurrencyFormatter.format(sale.discountAmount).padLeft(22)}');
    if (sale.taxAmount > 0)
      buf.writeln('Tax (${sale.taxRate}%): ${CurrencyFormatter.format(sale.taxAmount).padLeft(18)}');
    buf.writeln(line);
    buf.writeln('TOTAL: ${CurrencyFormatter.format(sale.total).padLeft(25)}');
    buf.writeln('Payment: ${sale.paymentMethod.label}');
    if (sale.paymentMethod == PaymentMethod.cash && sale.cashReceived > 0) {
      buf.writeln('Cash: ${CurrencyFormatter.format(sale.cashReceived).padLeft(26)}');
      buf.writeln('Change: ${CurrencyFormatter.format(sale.changeGiven).padLeft(24)}');
    }
    buf.writeln(line);
    buf.writeln(note.padLeft((32 + note.length) ~/ 2));
    buf.writeln();

    return buf.toString();
  }

  /// Build receipt as list of lines (for thermal printer ESC/POS)
  static List<String> generateReceiptLines(SaleModel sale) {
    return generateReceiptText(sale).split('\n');
  }

  /// Print via system share sheet (share as text)
  /// Connect a real thermal printer package here (e.g. esc_pos_bluetooth)
  static Future<void> printReceipt(SaleModel sale) async {
    // TODO: Integrate esc_pos_bluetooth or esc_pos_wifi package
    // For now — receipt text is available via generateReceiptText()
    // You can use the 'share_plus' package to share or save as file
    final text = generateReceiptText(sale);
    // ignore: avoid_print
    print(text); // placeholder
  }

  /// Check if a thermal printer is connected
  static Future<bool> isPrinterConnected() async {
    // TODO: implement with esc_pos_bluetooth
    return false;
  }
}
