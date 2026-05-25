// lib/main.dart
// StockPro — App Entry Point

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/sale_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/inventory_provider.dart';
import 'providers/report_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/navbar/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Firebase init
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => SaleProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
      ],
      child: const StockProApp(),
    ),
  );
}

class StockProApp extends StatelessWidget {
  const StockProApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeP = context.watch<ThemeProvider>();
    final auth   = context.watch<AuthProvider>();

    return MaterialApp(
      title: 'StockPro',
      debugShowCheckedModeBanner: false,
      theme:      AppTheme.lightTheme,
      darkTheme:  AppTheme.darkTheme,
      themeMode:  themeP.themeMode,
      home: auth.isLoggedIn
          ? const MainLayout()
          : const LoginScreen(),
    );
  }
}