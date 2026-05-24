// lib/features/navbar/main_layout.dart
// StockPro — Premium Navigation Shell (Sidebar + BottomNav)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../models/user_model.dart';
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
  int _index = 0;

  final _items = const [
    _NavItem(icon: Icons.dashboard_outlined,     activeIcon: Icons.dashboard_rounded,     label: 'Dashboard'),
    _NavItem(icon: Icons.point_of_sale_outlined, activeIcon: Icons.point_of_sale_rounded, label: 'Billing'),
    _NavItem(icon: Icons.inventory_2_outlined,   activeIcon: Icons.inventory_2_rounded,   label: 'Products'),
    _NavItem(icon: Icons.warehouse_outlined,     activeIcon: Icons.warehouse_rounded,     label: 'Stock'),
    _NavItem(icon: Icons.bar_chart_outlined,     activeIcon: Icons.bar_chart_rounded,     label: 'Reports'),
    _NavItem(icon: Icons.settings_outlined,      activeIcon: Icons.settings_rounded,      label: 'Settings'),
  ];

  final _screens = const [
    DashboardScreen(), PosScreen(), ProductsScreen(),
    InventoryScreen(), ReportsScreen(), SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().init();
      context.read<SaleProvider>().initToday();
      context.read<InventoryProvider>().init();
      context.read<ReportProvider>().loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = !ResponsiveHelper.isMobile(context);
    return isWide
        ? _SidebarLayout(items: _items, screens: _screens, index: _index,
        onTap: (i) => setState(() => _index = i))
        : _BottomNavLayout(items: _items, screens: _screens, index: _index,
        onTap: (i) => setState(() => _index = i));
  }
}

// ─── Mobile Bottom Nav ────────────────────────────────────────
class _BottomNavLayout extends StatelessWidget {
  final List<_NavItem> items;
  final List<Widget> screens;
  final int index;
  final ValueChanged<int> onTap;

  const _BottomNavLayout({
    required this.items, required this.screens,
    required this.index, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Only show 5 items in bottom nav (hide Settings)
    final navItems = items.take(5).toList();

    return Scaffold(
      body: IndexedStack(index: index, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              children: List.generate(navItems.length, (i) {
                final item    = navItems[i];
                final active  = index == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(i),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 4),
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.primary.withOpacity(0.12)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              active ? item.activeIcon : item.icon,
                              size: 22,
                              color: active
                                  ? AppColors.primary
                                  : (isDark
                                  ? AppColors.darkText3
                                  : AppColors.lightText3),
                            ),
                          ),
                          const SizedBox(height: 2),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: active
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: active
                                  ? AppColors.primary
                                  : (isDark
                                  ? AppColors.darkText3
                                  : AppColors.lightText3),
                            ),
                            child: Text(item.label),
                          ),
                        ],
                      ),
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

// ─── Desktop/Tablet Sidebar ───────────────────────────────────
class _SidebarLayout extends StatelessWidget {
  final List<_NavItem> items;
  final List<Widget> screens;
  final int index;
  final ValueChanged<int> onTap;

  const _SidebarLayout({
    required this.items, required this.screens,
    required this.index, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth   = context.watch<AuthProvider>();

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 220,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              border: Border(
                right: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
            ),
            child: Column(
              children: [
                // Logo section
                Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 20,
                    left: 20, right: 20, bottom: 20,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.storefront_rounded,
                            color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Text('StockPro',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          )),
                    ],
                  ),
                ),

                const Divider(height: 1),
                const SizedBox(height: 8),

                // Nav items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: List.generate(items.length, (i) {
                      final item   = items[i];
                      final active = index == i;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: ListTile(
                          onTap: () => onTap(i),
                          selected: active,
                          selectedTileColor: AppColors.primary.withOpacity(0.1),
                          selectedColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          leading: Icon(
                            active ? item.activeIcon : item.icon,
                            size: 20,
                            color: active
                                ? AppColors.primary
                                : (isDark
                                ? AppColors.darkText3
                                : AppColors.lightText3),
                          ),
                          title: Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight:
                              active ? FontWeight.w700 : FontWeight.w500,
                              color: active
                                  ? AppColors.primary
                                  : (isDark
                                  ? AppColors.darkText2
                                  : AppColors.lightText2),
                            ),
                          ),
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 0),
                          minLeadingWidth: 0,
                          horizontalTitleGap: 10,
                        ),
                      );
                    }),
                  ),
                ),

                // User section bottom
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightElevated,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primary.withOpacity(0.15),
                        child: Text(
                          auth.user?.initials ?? '?',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              auth.user?.name ?? 'User',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              auth.user?.role.label ?? '',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: isDark
                                      ? AppColors.darkText3
                                      : AppColors.lightText3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: IndexedStack(index: index, children: screens),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}