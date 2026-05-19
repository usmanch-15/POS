// lib/features/settings/tax_settings_screen.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/local_storage_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class TaxSettingsScreen extends StatefulWidget {
  const TaxSettingsScreen({super.key});

  @override
  State<TaxSettingsScreen> createState() => _TaxSettingsScreenState();
}

class _TaxSettingsScreenState extends State<TaxSettingsScreen> {
  final _gstRateCtrl   = TextEditingController(
      text: LocalStorageService.gstRate.toString());
  final _gstNumCtrl    = TextEditingController(
      text: LocalStorageService.gstNumber);
  final _lowStockCtrl  = TextEditingController(
      text: LocalStorageService.lowStockThreshold.toString());
  final _currencyCtrl  = TextEditingController(
      text: LocalStorageService.currency);
  bool _saving = false;

  @override
  void dispose() {
    _gstRateCtrl.dispose(); _gstNumCtrl.dispose();
    _lowStockCtrl.dispose(); _currencyCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await LocalStorageService.setGstRate(
        double.tryParse(_gstRateCtrl.text) ?? 0);
    await LocalStorageService.setGstNumber(_gstNumCtrl.text.trim());
    await LocalStorageService.setLowStockThreshold(
        int.tryParse(_lowStockCtrl.text) ?? 5);
    await LocalStorageService.setCurrency(_currencyCtrl.text.trim());
    setState(() => _saving = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Tax settings saved!'),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(
        title: const Text('Tax & Preferences',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          child: Column(children: [
            CustomTextField.number(
                label: 'GST Rate (%)', controller: _gstRateCtrl),
            const SizedBox(height: 14),
            CustomTextField(
                label: 'GST / NTN Number', controller: _gstNumCtrl),
            const SizedBox(height: 14),
            CustomTextField(
                label: 'Currency Symbol (e.g. PKR)',
                controller: _currencyCtrl),
            const SizedBox(height: 14),
            CustomTextField.number(
                label: 'Low Stock Alert Threshold',
                controller: _lowStockCtrl,
                decimal: false),
            const SizedBox(height: 24),
            CustomButton(
                label: 'Save Changes',
                onPressed: _save,
                loading: _saving),
          ]),
        ),
      ),
    );
  }
}
