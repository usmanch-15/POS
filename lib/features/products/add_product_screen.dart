// lib/features/products/add_product_screen.dart
// StockPro — Premium Add / Edit Product Screen

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/premium_widgets.dart';
import '../../models/product_model.dart';
import '../../models/category_model.dart';
import '../../providers/product_provider.dart';

class AddProductScreen extends StatefulWidget {
  final ProductModel? product;
  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey       = GlobalKey<FormState>();
  final _nameCtrl      = TextEditingController();
  final _salePriceCtrl = TextEditingController();
  final _costPriceCtrl = TextEditingController();
  final _quantityCtrl  = TextEditingController();
  final _barcodeCtrl   = TextEditingController();
  final _minStockCtrl  = TextEditingController(text: '5');
  final _descCtrl      = TextEditingController();

  String _category  = CategoryModel.defaults.first;
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
    _nameCtrl.dispose(); _salePriceCtrl.dispose();
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
      barcode:       _barcodeCtrl.text.trim().isEmpty ? null : _barcodeCtrl.text.trim(),
      salePrice:     double.parse(_salePriceCtrl.text),
      costPrice:     double.parse(_costPriceCtrl.text),
      quantity:      int.parse(_quantityCtrl.text),
      minStockLevel: int.tryParse(_minStockCtrl.text) ?? 5,
      description:   _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      createdAt:     _isEdit ? widget.product!.createdAt : DateTime.now(),
    );

    final prov = context.read<ProductProvider>();
    final ok   = _isEdit
        ? await prov.updateProduct(product)
        : await prov.addProduct(product);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEdit ? 'Product updated!' : 'Product added!'),
        backgroundColor: AppColors.success,
      ));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Something went wrong'),
        backgroundColor: AppColors.danger,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Product' : 'Add Product'),
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Basic info card
            PremiumCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Basic Information',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Product Name *',
                    hint: 'e.g. Coca Cola 500ml',
                    controller: _nameCtrl,
                    validator: (v) =>
                    v == null || v.isEmpty ? 'Name required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Category dropdown
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Category',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkText2 : AppColors.lightText2,
                          )),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _category,
                        decoration: const InputDecoration(),
                        items: CategoryModel.defaults
                            .map((c) => DropdownMenuItem(
                            value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _category = v!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Barcode (optional)',
                    hint: 'Scan or enter barcode',
                    controller: _barcodeCtrl,
                    prefixIcon: const Icon(Icons.qr_code_rounded, size: 18),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Description (optional)',
                    hint: 'Product details...',
                    controller: _descCtrl,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Pricing card
            PremiumCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pricing',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(
                      child: AppTextField.number(
                        label: 'Sale Price *',
                        hint: '0.00',
                        controller: _salePriceCtrl,
                        validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField.number(
                        label: 'Cost Price *',
                        hint: '0.00',
                        controller: _costPriceCtrl,
                        validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Stock card
            PremiumCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Stock',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Quantity *',
                        hint: '0',
                        controller: _quantityCtrl,
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: 'Min. Stock Level',
                        hint: '5',
                        controller: _minStockCtrl,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 24),

            GradientButton(
              label: _isEdit ? 'Update Product' : 'Add Product',
              icon: _isEdit ? Icons.save_rounded : Icons.add_rounded,
              loading: _isLoading,
              onPressed: _save,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}