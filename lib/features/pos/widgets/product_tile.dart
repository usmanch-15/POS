// lib/features/pos/widgets/product_tile.dart
// StockPro — Premium Product Tile for POS Grid

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/product_model.dart';
import '../../../providers/cart_provider.dart';

class ProductTile extends StatefulWidget {
  final ProductModel product;
  const ProductTile({super.key, required this.product});

  @override
  State<ProductTile> createState() => _ProductTileState();
}

class _ProductTileState extends State<ProductTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.94)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTap() async {
    if (widget.product.isOutOfStock) return;
    await _ctrl.forward();
    await _ctrl.reverse();
    if (!mounted) return;
    context.read<CartProvider>().addProduct(widget.product);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_rounded,
              color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Expanded(
              child: Text('${widget.product.name} added to cart',
                  style: const TextStyle(fontSize: 13))),
        ]),
        backgroundColor: AppColors.success,
        duration: const Duration(milliseconds: 1200),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final isOut      = widget.product.isOutOfStock;
    final isLow      = widget.product.isLowStock;
    final colorIndex =
        widget.product.name.codeUnits.first % AppColors.chartColors.length;
    final chipColor  = AppColors.chartColors[colorIndex];

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: _onTap,
        child: Opacity(
          opacity: isOut ? 0.5 : 1.0,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isOut
                    ? AppColors.danger.withOpacity(0.3)
                    : isLow
                    ? AppColors.warning.withOpacity(0.4)
                    : (isDark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category chip
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: chipColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(widget.product.category,
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: chipColor),
                      overflow: TextOverflow.ellipsis),
                ),
                const Spacer(),

                // Product icon
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: chipColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.inventory_2_rounded,
                      color: chipColor, size: 18),
                ),
                const SizedBox(height: 8),

                // Name
                Text(
                  widget.product.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkText1 : AppColors.lightText1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Price + stock
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      CurrencyFormatter.format(widget.product.salePrice),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    if (isOut)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.dangerLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Out',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.danger)),
                      )
                    else if (isLow)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.warningLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('${widget.product.quantity}',
                            style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.warning)),
                      )
                    else
                      Text(
                        '${widget.product.quantity} left',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark
                              ? AppColors.darkText3
                              : AppColors.lightText3,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}