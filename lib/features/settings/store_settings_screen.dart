// lib/features/settings/store_settings_screen.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/local_storage_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class StoreSettingsScreen extends StatefulWidget {
  const StoreSettingsScreen({super.key});

  @override
  State<StoreSettingsScreen> createState() => _StoreSettingsScreenState();
}

class _StoreSettingsScreenState extends State<StoreSettingsScreen> {
  final _nameCtrl    = TextEditingController(text: LocalStorageService.businessName);
  final _ownerCtrl   = TextEditingController(text: LocalStorageService.ownerName);
  final _phoneCtrl   = TextEditingController(text: LocalStorageService.phone);
  final _addressCtrl = TextEditingController(text: LocalStorageService.address);
  final _noteCtrl    = TextEditingController(text: LocalStorageService.receiptNote);
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose(); _ownerCtrl.dispose();
    _phoneCtrl.dispose(); _addressCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await LocalStorageService.setBusinessName(_nameCtrl.text.trim());
    await LocalStorageService.setOwnerName(_ownerCtrl.text.trim());
    await LocalStorageService.setPhone(_phoneCtrl.text.trim());
    await LocalStorageService.setAddress(_addressCtrl.text.trim());
    await LocalStorageService.setReceiptNote(_noteCtrl.text.trim());
    setState(() => _saving = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Settings saved!'),
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
        title: const Text('Store Information',
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
            CustomTextField(
                label: 'Business Name', controller: _nameCtrl),
            const SizedBox(height: 14),
            CustomTextField(
                label: 'Owner Name', controller: _ownerCtrl),
            const SizedBox(height: 14),
            CustomTextField(
                label: 'Phone',
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 14),
            CustomTextField(
                label: 'Address',
                controller: _addressCtrl,
                maxLines: 2),
            const SizedBox(height: 14),
            CustomTextField(
                label: 'Receipt Footer Note',
                controller: _noteCtrl,
                maxLines: 2),
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
