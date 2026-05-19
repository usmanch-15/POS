// lib/features/auth/login_screen.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Login Screen
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'widgets/logo_header.dart';
import 'widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
      isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LogoHeader(),
              SizedBox(height: 36),
              LoginForm(),
            ],
          ),
        ),
      ),
    );
  }
}