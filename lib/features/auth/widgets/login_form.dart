// lib/features/auth/widgets/login_form.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Login Form Widget
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey    = GlobalKey<FormState>();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus  = FocusNode();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final auth = context.read<AuthProvider>();
    final ok   = await auth.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Login failed'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Email ─────────────────────────────────────────
          CustomTextField(
            label:       'Email',
            hint:        'you@example.com',
            controller:  _emailCtrl,
            focusNode:   _emailFocus,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            prefixIcon:  const Icon(Icons.email_outlined, size: AppDimensions.iconMd),
            onSubmitted: (_) => _passFocus.requestFocus(),
            validator:   (v) {
              if (v == null || v.isEmpty) return 'Email daalen';
              if (!v.contains('@')) return 'Valid email likhein';
              return null;
            },
          ),

          const SizedBox(height: 16),

          // ── Password ──────────────────────────────────────
          CustomTextField.password(
            label:      'Password',
            controller: _passCtrl,
            focusNode:  _passFocus,
            validator:  (v) {
              if (v == null || v.isEmpty) return 'Password daalen';
              if (v.length < 6) return 'Min 6 characters chahiye';
              return null;
            },
          ),

          const SizedBox(height: 28),

          // ── Login Button ──────────────────────────────────
          CustomButton(
            label:     'Login',
            onPressed: isLoading ? null : _submit,
            loading:   isLoading,
          ),

          const SizedBox(height: 24),

          // ── Role info ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.07),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(color: AppColors.primary.withOpacity(0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 15, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text('User Roles',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      )),
                ]),
                const SizedBox(height: 8),
                _roleRow(Icons.shield_outlined, 'Admin',
                    'Full access — products, reports, users'),
                const SizedBox(height: 4),
                _roleRow(Icons.manage_accounts_outlined, 'Manager',
                    'Products, sales, reports'),
                const SizedBox(height: 4),
                _roleRow(Icons.person_outline_rounded, 'Cashier',
                    'Billing only'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleRow(IconData icon, String role, String desc) {
    return Row(children: [
      Icon(icon, size: 13, color: AppColors.primary),
      const SizedBox(width: 5),
      Text('$role — ',
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
      Expanded(
        child: Text(desc,
            style: const TextStyle(fontSize: 11, color: AppColors.primary),
            overflow: TextOverflow.ellipsis),
      ),
    ]);
  }
}
