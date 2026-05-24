import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/currency_formatter.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/signup_screen.dart'; // ✅ ADD
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

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes:     Settings.CACHE_SIZE_UNLIMITED,
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
            title:                     'StockPro',
            debugShowCheckedModeBanner: false,
            themeMode:                 themeProvider.themeMode,
            theme:                     AppTheme.lightTheme,
            darkTheme:                 AppTheme.darkTheme,
            home:                      const _AuthGate(),
            // ✅ Routes add kiye
            routes: {
              '/login':  (_) => const LoginScreen(),
              '/signup': (_) => const SignupScreen(),
            },
          );
        },
      ),
    );
  }
}

// ── Auth Gate ──────────────────────────────────────────────────
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