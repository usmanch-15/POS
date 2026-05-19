// lib/features/settings/settings_screen.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Settings Screen
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/confirm_dialog.dart';
import 'store_settings_screen.dart';
import 'tax_settings_screen.dart';
import 'widgets/settings_tile.dart';
import 'widgets/toggle_setting.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final auth    = context.watch<AuthProvider>();
    final themeP  = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(
        title: const Text('Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Profile card ──────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    auth.user?.initials ?? '?',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(auth.user?.name ?? 'User',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                Text(auth.user?.role.label ?? '',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12)),
                Text(auth.user?.email ?? '',
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 11)),
              ]),
            ]),
          ),
          const SizedBox(height: 20),

          // ── Appearance ────────────────────────────────
          _sectionTitle('Appearance'),
          ToggleSetting(
            icon:    Icons.dark_mode_outlined,
            label:   'Dark Mode',
            value:   themeP.isDark,
            onToggle: themeP.setDarkMode,
          ),
          const SizedBox(height: 16),

          // ── Business ──────────────────────────────────
          _sectionTitle('Business'),
          SettingsTile(
            icon:    Icons.store_outlined,
            label:   'Store Information',
            sub:     'Name, address, phone',
            onTap:   () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => const StoreSettingsScreen())),
          ),
          SettingsTile(
            icon:    Icons.percent_rounded,
            label:   'Tax Settings',
            sub:     'GST / NTN configuration',
            onTap:   () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => const TaxSettingsScreen())),
          ),
          const SizedBox(height: 16),

          // ── App info ──────────────────────────────────
          _sectionTitle('App'),
          SettingsTile(
            icon:    Icons.info_outline_rounded,
            label:   'Version',
            sub:     'StockPro v1.0.0',
            onTap:   null,
            trailing: const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),

          // ── Logout ────────────────────────────────────
          SettingsTile(
            icon:    Icons.logout_rounded,
            label:   'Logout',
            sub:     'Sign out of your account',
            iconColor: AppColors.danger,
            labelColor: AppColors.danger,
            onTap:   () async {
              final ok = await ConfirmDialog.show(
                context,
                title:   'Logout',
                message: 'Are you sure you want to logout?',
                confirmLabel: 'Logout',
              );
              if (ok && context.mounted) {
                context.read<AuthProvider>().logout();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.lightText3,
              letterSpacing: 0.5)),
    );
  }
}
