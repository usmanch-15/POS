
//  FILE 2:  lib/services/printer_service.dart  ← PURANI FILE REPLACE KARO
//
//  PART 4 — FIX:
//   FIX-4C: Actual receipt share + PDF export implement kiya
//            pehle sirf print() tha (stub)
//
//   ZAROORI — pubspec.yaml mein add karo:
//     dependencies:
//       pdf: ^3.11.0
//       printing: ^5.12.0
//       share_plus: ^9.0.0
// ═══════════════════════════════════════════════════════════════

// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';

import '../models/sale_model.dart';
import '../services/local_storage_service.dart';
import '../core/utils/currency_formatter.dart';
import '../core/utils/date_formatter.dart';

class PrinterService {
// ── FIX-4C: PDF generate karo ──────────────────────────────
static Future<Uint8List> generateReceiptPdf(SaleModel sale) async {
final doc = pw.Document();

final biz    = LocalStorageService.businessName;
final addr   = LocalStorageService.address;
final phone  = LocalStorageService.phone;
final note   = LocalStorageService.receiptNote;

doc.addPage(pw.Page(
pageFormat: PdfPageFormat.roll80,         // 80mm thermal paper
margin:     const pw.EdgeInsets.all(8),
build: (_) => pw.Column(
crossAxisAlignment: pw.CrossAxisAlignment.stretch,
children: [
// Header
pw.Center(child: pw.Text(biz.toUpperCase(),
style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold))),
if (addr.isNotEmpty)
pw.Center(child: pw.Text(addr, style: const pw.TextStyle(fontSize: 9))),
if (phone.isNotEmpty)
pw.Center(child: pw.Text(phone, style: const pw.TextStyle(fontSize: 9))),
pw.Divider(),

// Bill info
pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
pw.Text('Bill: ${sale.billNumber}', style: const pw.TextStyle(fontSize: 9)),
pw.Text(DateFormatter.dateTime(sale.createdAt), style: const pw.TextStyle(fontSize: 9)),
]),
if (sale.customerName != null)
pw.Text('Customer: ${sale.customerName}', style: const pw.TextStyle(fontSize: 9)),
pw.Divider(),

// Items
...sale.items.map((item) => pw.Padding(
padding: const pw.EdgeInsets.symmetric(vertical: 2),
child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
pw.Expanded(child: pw.Text(item.productName, style: const pw.TextStyle(fontSize: 9))),
pw.Text(CurrencyFormatter.formatNumber(item.total), style: const pw.TextStyle(fontSize: 9)),
]),
pw.Text('  ${item.quantity} x ${CurrencyFormatter.formatNumber(item.salePrice)}',
style: const pw.TextStyle(fontSize: 8)),
]),
)),
pw.Divider(),

// Totals
_row('Subtotal', CurrencyFormatter.format(sale.subtotal)),
if (sale.discountAmount > 0)
_row('Discount', '-${CurrencyFormatter.format(sale.discountAmount)}'),
if (sale.taxAmount > 0)
_row('Tax (${sale.taxRate}%)', CurrencyFormatter.format(sale.taxAmount)),
pw.Divider(),
pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
pw.Text('TOTAL', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
pw.Text(CurrencyFormatter.format(sale.total),
style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
]),
pw.SizedBox(height: 4),
pw.Text('Payment: ${sale.paymentMethod.label}', style: const pw.TextStyle(fontSize: 9)),
if (sale.paymentMethod == PaymentMethod.cash && sale.cashReceived > 0) ...[
_row('Cash', CurrencyFormatter.format(sale.cashReceived)),
_row('Change', CurrencyFormatter.format(sale.changeGiven)),
],
pw.Divider(),
pw.Center(child: pw.Text(note, style: const pw.TextStyle(fontSize: 8))),
],
),
));

return doc.save();
}

// ── FIX-4C: System print dialog ────────────────────────────
// Flutter printing package ka use karta hai — WiFi/Bluetooth printers
static Future<void> printReceipt(BuildContext context, SaleModel sale) async {
final pdfBytes = await generateReceiptPdf(sale);
await Printing.layoutPdf(onLayout: (_) async => pdfBytes);
}

// ── FIX-4C: WhatsApp/Email se share karo ───────────────────
static Future<void> shareReceipt(SaleModel sale) async {
final pdfBytes = await generateReceiptPdf(sale);
final xFile    = XFile.fromData(
pdfBytes,
name:     'Receipt_${sale.billNumber}.pdf',
mimeType: 'application/pdf',
);
await Share.shareXFiles(
[xFile],
subject: 'Receipt ${sale.billNumber}',
text:    'Receipt from ${LocalStorageService.businessName}',
);
}

// ── Plain text receipt (thermal printer ke liye) ───────────
static String generateReceiptText(SaleModel sale) {
final biz   = LocalStorageService.businessName;
final note  = LocalStorageService.receiptNote;
final line  = '─' * 32;
final buf   = StringBuffer();

buf.writeln(biz.toUpperCase().padLeft((32 + biz.length) ~/ 2));
buf.writeln(line);
buf.writeln('Bill: ${sale.billNumber}');
buf.writeln('Date: ${DateFormatter.dateTime(sale.createdAt)}');
if (sale.customerName != null) buf.writeln('Cust: ${sale.customerName}');
buf.writeln(line);
for (final item in sale.items) {
final name  = item.productName.length > 18
? item.productName.substring(0, 18)
    : item.productName;
buf.writeln('${name.padRight(22)}${CurrencyFormatter.formatNumber(item.total).padLeft(10)}');
buf.writeln('  ${item.quantity} x ${CurrencyFormatter.formatNumber(item.salePrice)}');
}
buf.writeln(line);
buf.writeln('TOTAL: ${CurrencyFormatter.format(sale.total).padLeft(25)}');
buf.writeln(line);
buf.writeln(note);
return buf.toString();
}

// ── Helper ──────────────────────────────────────────────────
static pw.Widget _row(String label, String value) =>
pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
pw.Text(value, style: const pw.TextStyle(fontSize: 9)),
]);
}
