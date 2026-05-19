// lib/features/pos/widgets/barcode_scanner_bar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/cart_provider.dart';

class BarcodeScannerBar extends StatefulWidget {
  final void Function(String) onSearch;
  const BarcodeScannerBar({super.key, required this.onSearch});

  @override
  State<BarcodeScannerBar> createState() => _BarcodeScannerBarState();
}

class _BarcodeScannerBarState extends State<BarcodeScannerBar> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit(String val) async {
    final trimmed = val.trim();
    if (trimmed.isEmpty) return;

    // Try barcode lookup first
    final product = await context.read<ProductProvider>().getByBarcode(trimmed);
    if (product != null && mounted) {
      context.read<CartProvider>().addProduct(product);
      _ctrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${product.name} added'),
        backgroundColor: AppColors.success,
        duration: const Duration(milliseconds: 700),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    } else {
      widget.onSearch(trimmed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      color: isDark ? AppColors.darkCard : Colors.white,
      child: TextField(
        controller: _ctrl,
        onChanged: widget.onSearch,
        onSubmitted: _onSubmit,
        decoration: InputDecoration(
          hintText: 'Search or scan barcode...',
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          suffixIcon: IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded,
                color: AppColors.primary),
            onPressed: () {}, // TODO: mobile camera scanner
          ),
          filled: true,
          fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
      ),
    );
  }
}
