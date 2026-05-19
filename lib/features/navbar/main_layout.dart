// lib/features/navbar/main_layout.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Main App Shell (Sidebar + BottomNav)
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/responsive_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/report_provider.dart';
import '../dashboard/dashboard_screen.dart';
import '../pos/pos_screen.dart';
import '../products/products_screen.dart';
import '../inventory/inventory_screen.dart';
import '../reports/reports_screen.dart';
import '../settings/settings_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.dashboard_outlined,      activeIcon: Icons.dashboard_rounded,          label: 'Dashboard'),
    _NavItem(icon: Icons.point_of_sale_outlined,  activeIcon: Icons.point_of_sale_rounded,      label: 'Billing'),
    _NavItem(icon: Icons.inventory_2_outlined,    activeIcon: Icons.inventory_2_rounded,        label: 'Products'),
    _NavItem(icon: Icons.warehouse_outlined,      activeIcon: Icons.warehouse_rounded,          label: 'Stock'),
    _NavItem(icon: Icons.bar_chart_outlined,      activeIcon: Icons.bar_chart_rounded,          label: 'Reports'),
    _NavItem(icon: Icons.settings_outlined,       activeIcon: Icons.settings_rounded,           label: 'Settings'),
  ];

  final List<Widget> _screens = const [
    DashboardScreen(),
    PosScreen(),
    ProductsScreen(),
    InventoryScreen(),
    ReportsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initProviders());
  }

  void _initProviders() {
    context.read<ProductProvider>().init();
    context.read<SaleProvider>().initToday();
    context.read<InventoryProvider>().init();
    context.read<ReportProvider>().loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context) || ResponsiveHelper.isTablet(context)) {
      return _DesktopLayout(
        navItems:     _navItems,
        screens:      _screens,
        currentIndex: _currentIndex,
        onTap:        (i) => setState(() => _currentIndex = i),
      );
    }
    return _MobileLayout(
      navItems:     _navItems,
      screens:      _screens,
      currentIndex: _currentIndex,
      onTap:        (i) => setState(() => _currentIndex = i),
    );
  }
}

// ── Desktop / Tablet — NavigationRail ─────────────────────────
class _DesktopLayout extends StatelessWidget {
  final List<_NavItem> navItems;
  final List<Widget>   screens;
  final int            currentIndex;
  final void Function(int) onTap;

  const _DesktopLayout({
    required this.navItems,
    required this.screens,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Row(
        children: [
          // ── Sidebar ───────────────────────────────────────
          Container(
            width: 220,
            color: isDark ? AppColors.darkCard : Colors.white,
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Logo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.storefront_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Text('StockPro',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                  ]),
                ),
                const SizedBox(height: 28),
                // Nav items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: navItems.length,
                    itemBuilder: (_, i) {
                      final item     = navItems[i];
                      final selected = i == currentIndex;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                          child: InkWell(
                            onTap: () => onTap(i),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primary.withOpacity(0.12)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                              ),
                              child: Row(children: [
                                Icon(
                                  selected ? item.activeIcon : item.icon,
                                  size: 20,
                                  color: selected
                                      ? AppColors.primary
                                      : (isDark ? AppColors.darkText2 : AppColors.lightText2),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  item.label,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: selected
                                        ? AppColors.primary
                                        : (isDark ? AppColors.darkText2 : AppColors.lightText2),
                                  ),
                                ),
                              ]),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Logout
                const Divider(height: 1),
                _LogoutTile(),
                const SizedBox(height: 12),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          // ── Content ───────────────────────────────────────
          Expanded(child: screens[currentIndex]),
        ],
      ),
    );
  }
}

// ── Mobile — BottomNavigationBar ──────────────────────────────
class _MobileLayout extends StatelessWidget {
  final List<_NavItem> navItems;
  final List<Widget>   screens;
  final int            currentIndex;
  final void Function(int) onTap;

  const _MobileLayout({
    required this.navItems,
    required this.screens,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Show only first 5 items in bottom nav
    final bottomItems = navItems.take(5).toList();

    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: AppDimensions.bottomNavHeight,
            child: Row(
              children: List.generate(bottomItems.length, (i) {
                final item     = bottomItems[i];
                final selected = i == currentIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(i),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          selected ? item.activeIcon : item.icon,
                          size: 22,
                          color: selected
                              ? AppColors.primary
                              : (isDark ? AppColors.darkText3 : AppColors.lightText3),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: selected
                                ? AppColors.primary
                                : (isDark ? AppColors.darkText3 : AppColors.lightText3),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Logout tile ───────────────────────────────────────────────
class _LogoutTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: const Icon(Icons.logout_rounded,
          size: 20, color: AppColors.danger),
      title: const Text('Logout',
          style: TextStyle(fontSize: 14, color: AppColors.danger)),
      onTap: () async {
        await context.read<AuthProvider>().logout();
      },
    );
  }
}

// ── Nav item data ─────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String   label;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
