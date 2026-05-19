// lib/features/inventory/stock_adjustment_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/product_model.dart';
import '../../models/stock_model.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class StockAdjustmentScreen extends StatefulWidget {
  final ProductModel product;
  const StockAdjustmentScreen({super.key, required this.product});

  @override
  State<StockAdjustmentScreen> createState() => _StockAdjustmentScreenState();
}

class _StockAdjustmentScreenState extends State<StockAdjustmentScreen> {
  final _qtyCtrl    = TextEditingController();
  final _reasonCtrl = TextEditingController();
  StockMovementType _type = StockMovementType.stockIn;
  bool _isLoading = false;

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final qty = int.tryParse(_qtyCtrl.text.trim());
    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Valid quantity daalen'),
        backgroundColor: AppColors.danger,
      ));
      return;
    }

    setState(() => _isLoading = true);
    final auth     = context.read<AuthProvider>();
    final inventory = context.read<InventoryProvider>();

    int newQty;
    if (_type == StockMovementType.stockIn) {
      newQty = widget.product.quantity + qty;
    } else if (_type == StockMovementType.stockOut) {
      newQty = (widget.product.quantity - qty).clamp(0, 999999);
    } else {
      newQty = qty; // direct adjustment
    }

    final ok = await inventory.adjustStock(
      product:     widget.product,
      newQuantity: newQty,
      reason:      _reasonCtrl.text.trim().isEmpty
          ? _type.label : _reasonCtrl.text.trim(),
      addedBy:     auth.userName,
      type:        _type,
    );

    setState(() => _isLoading = false);
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Stock updated!'),
        backgroundColor: AppColors.success,
      ));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(
        title: const Text('Adjust Stock',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Product info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.inventory_2_outlined,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.product.name,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  Text('Current Stock: ${widget.product.quantity} units',
                      style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkText3
                              : AppColors.lightText3)),
                ],
              )),
            ]),
          ),
          const SizedBox(height: 16),

          // Type selector
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Adjustment Type',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(children: [
                  _TypeBtn(label: 'Stock In',  type: StockMovementType.stockIn,    selected: _type, onTap: (t) => setState(() => _type = t)),
                  const SizedBox(width: 8),
                  _TypeBtn(label: 'Stock Out', type: StockMovementType.stockOut,   selected: _type, onTap: (t) => setState(() => _type = t)),
                  const SizedBox(width: 8),
                  _TypeBtn(label: 'Set Qty',   type: StockMovementType.adjustment, selected: _type, onTap: (t) => setState(() => _type = t)),
                ]),
                const SizedBox(height: 16),
                CustomTextField.number(
                  label: _type == StockMovementType.adjustment
                      ? 'New Quantity' : 'Quantity',
                  controller: _qtyCtrl,
                  decimal:    false,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label:      'Reason (optional)',
                  hint:       'e.g. Received from supplier',
                  controller: _reasonCtrl,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            label:     'Update Stock',
            onPressed: _save,
            loading:   _isLoading,
          ),
        ]),
      ),
    );
  }
}

class _TypeBtn extends StatelessWidget {
  final String             label;
  final StockMovementType  type;
  final StockMovementType  selected;
  final void Function(StockMovementType) onTap;

  const _TypeBtn({
    required this.label,
    required this.type,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = type == selected;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.white : AppColors.primary)),
          ),
        ),
      ),
    );
  }
}
