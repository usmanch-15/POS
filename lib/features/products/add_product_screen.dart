// lib/features/products/add_product_screen.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Add / Edit Product Screen
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../models/product_model.dart';
import '../../models/category_model.dart';
import '../../providers/product_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddProductScreen extends StatefulWidget {
  final ProductModel? product; // null = add mode
  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _nameCtrl     = TextEditingController();
  final _salePriceCtrl = TextEditingController();
  final _costPriceCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _barcodeCtrl  = TextEditingController();
  final _minStockCtrl = TextEditingController(text: '5');
  final _descCtrl     = TextEditingController();

  String _category = CategoryModel.defaults.first;
  bool   _isLoading = false;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final p = widget.product!;
      _nameCtrl.text      = p.name;
      _salePriceCtrl.text = p.salePrice.toString();
      _costPriceCtrl.text = p.costPrice.toString();
      _quantityCtrl.text  = p.quantity.toString();
      _barcodeCtrl.text   = p.barcode ?? '';
      _minStockCtrl.text  = p.minStockLevel.toString();
      _descCtrl.text      = p.description ?? '';
      _category           = p.category;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();  _salePriceCtrl.dispose();
    _costPriceCtrl.dispose(); _quantityCtrl.dispose();
    _barcodeCtrl.dispose(); _minStockCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);

    final product = ProductModel(
      id:            _isEdit ? widget.product!.id : '',
      name:          _nameCtrl.text.trim(),
      category:      _category,
      barcode:       _barcodeCtrl.text.trim().isEmpty
          ? null : _barcodeCtrl.text.trim(),
      salePrice:     double.parse(_salePriceCtrl.text),
      costPrice:     double.parse(_costPriceCtrl.text),
      quantity:      int.parse(_quantityCtrl.text),
      minStockLevel: int.tryParse(_minStockCtrl.text) ?? 5,
      description:   _descCtrl.text.trim().isEmpty
          ? null : _descCtrl.text.trim(),
      createdAt:     _isEdit
          ? widget.product!.createdAt : DateTime.now(),
    );

    final provider = context.read<ProductProvider>();
    final ok = _isEdit
        ? await provider.updateProduct(product)
        : await provider.addProduct(product);

    setState(() => _isLoading = false);
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEdit
            ? 'Product updated!' : 'Product added!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(provider.error ?? 'Something went wrong'),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Product' : 'Add Product',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            // ── Basic Info ────────────────────────────
            _section('Basic Info', [
              CustomTextField(
                label: 'Product Name',
                hint:  'e.g. Lays Classic',
                controller: _nameCtrl,
                validator: (v) => v == null || v.isEmpty
                    ? 'Name required' : null,
              ),
              const SizedBox(height: 14),
              // Category dropdown
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                    labelText: 'Category'),
                items: CategoryModel.defaults
                    .map((c) => DropdownMenuItem(
                        value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _category = v!),
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Barcode (optional)',
                hint:  '123456789012',
                controller: _barcodeCtrl,
                prefixIcon: const Icon(Icons.qr_code_rounded,
                    size: AppDimensions.iconMd),
              ),
            ]),

            const SizedBox(height: 16),

            // ── Pricing ───────────────────────────────
            _section('Pricing', [
              Row(children: [
                Expanded(
                  child: CustomTextField.number(
                    label:      'Sale Price',
                    controller: _salePriceCtrl,
                    prefix:     'PKR',
                    validator:  (v) => v == null || v.isEmpty
                        ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField.number(
                    label:      'Cost Price',
                    controller: _costPriceCtrl,
                    prefix:     'PKR',
                    validator:  (v) => v == null || v.isEmpty
                        ? 'Required' : null,
                  ),
                ),
              ]),
            ]),

            const SizedBox(height: 16),

            // ── Stock ─────────────────────────────────
            _section('Stock', [
              Row(children: [
                Expanded(
                  child: CustomTextField.number(
                    label:      'Opening Stock',
                    controller: _quantityCtrl,
                    decimal:    false,
                    validator:  (v) => v == null || v.isEmpty
                        ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField.number(
                    label:      'Low Stock Alert',
                    controller: _minStockCtrl,
                    decimal:    false,
                  ),
                ),
              ]),
            ]),

            const SizedBox(height: 16),

            // ── Description ───────────────────────────
            _section('Description (optional)', [
              CustomTextField(
                label:    'Description',
                hint:     'Additional notes...',
                controller: _descCtrl,
                maxLines: 3,
              ),
            ]),

            const SizedBox(height: 24),

            CustomButton(
              label:     _isEdit ? 'Update Product' : 'Add Product',
              onPressed: _save,
              loading:   _isLoading,
            ),
          ]),
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
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
          Text(title,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: AppColors.primary)),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
