// lib/main.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Entry Point
//  FIXES:
//   1. Firestore offline persistence enable kiya — internet band
//      hone pe POS kaam karta rahega (cached data se)
//   2. AppBar Colors.white hardcoded tha — ab theme se aata hai
//      (AppTheme mein appBarTheme set karo — example neeche hai)
// ─────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/currency_formatter.dart';
import 'features/auth/login_screen.dart';
import 'services/local_storage_service.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';
import 'providers/sale_provider.dart';
import 'providers/inventory_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/report_provider.dart';
import 'providers/theme_provider.dart';
import 'features/navbar/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ── FIX #1: Firestore offline persistence enable karo ─────
  // Pehle yeh line nahi thi — internet band hone pe POS freeze
  // ho jata tha. Ab Firestore local disk pe data cache karta hai.
  // User offline hone pe bhi products, customers, recent sales
  // dekh sakta hai. Internet wapas aane pe automatically sync hoga.
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled:    true,
    cacheSizeBytes:        Settings.CACHE_SIZE_UNLIMITED,
  );

  await LocalStorageService.init();
  CurrencyFormatter.setSymbol(LocalStorageService.currency);

  runApp(const StockProApp());
}

class StockProApp extends StatelessWidget {
  const StockProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => SaleProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_, themeProvider, __) {
          return MaterialApp(
            title:                    'StockPro',
            debugShowCheckedModeBanner: false,
            themeMode:                themeProvider.themeMode,
            // FIX #2: AppTheme mein appBarTheme set karo
            // ab har screen ka AppBar theme se color lega —
            // Colors.white hardcode mat karo kisi screen mein.
            //
            // AppTheme.lightTheme mein yeh add karo:
            //   appBarTheme: const AppBarTheme(
            //     backgroundColor: Colors.white,
            //     foregroundColor: AppColors.textDark,
            //     elevation: 0,
            //   ),
            // AppTheme.darkTheme mein yeh add karo:
            //   appBarTheme: AppBarTheme(
            //     backgroundColor: AppColors.darkSurface,
            //     foregroundColor: Colors.white,
            //     elevation: 0,
            //   ),
            //
            // Phir screens mein sirf yeh likho:
            //   AppBar(title: Text('Screen Name'))
            // backgroundColor mat dena — theme se automatically aayega.
            theme:     AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home:      const _AuthGate(),
          );
        },
      ),
    );
  }
}

// ── Auth Gate ─────────────────────────────────────────────────
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    switch (auth.status) {
      case AuthStatus.loading:
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
        );
      case AuthStatus.authenticated:
        return const MainLayout();
      case AuthStatus.unauthenticated:
        return const LoginScreen();
    }
  }
}