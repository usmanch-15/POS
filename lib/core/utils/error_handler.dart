// ═══════════════════════════════════════════════════════════════
//  FILE 1:  lib/core/utils/error_handler.dart  ← YEH FILE NAHI THI
//           Nai file hai — apne project mein banao
//
//  PART 6 — FIX:
//   FIX-6A: Provider errors silently consume hote the — user ko
//            kuch pata nahi chalta tha. Ab ErrorHandler.show() se
//            har jagah consistent SnackBar/dialog aata hai.
//
//   Use karo:
//     ErrorHandler.show(context, 'Product save nahi hua');
//     ErrorHandler.showSuccess(context, 'Product save ho gaya!');
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ErrorHandler {
  ErrorHandler._();

  // ── Error SnackBar ──────────────────────────────────────────
  static void show(BuildContext context, String? message, {
    String fallback = 'Kuch masla aa gaya. Dobara koshish karein.',
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;
    final msg = (message == null || message.isEmpty) ? fallback : _friendly(message);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(msg, style: const TextStyle(fontSize: 13))),
        ]),
        backgroundColor: AppColors.danger,
        behavior:        SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration:        duration,
      ));
  }

  // ── Success SnackBar ────────────────────────────────────────
  static void showSuccess(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 13))),
        ]),
        backgroundColor: AppColors.success,
        behavior:        SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration:        const Duration(seconds: 2),
      ));
  }

  // ── Warning SnackBar ────────────────────────────────────────
  static void showWarning(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.warning_amber_outlined, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 13))),
        ]),
        backgroundColor: Colors.orange.shade700,
        behavior:        SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration:        const Duration(seconds: 3),
      ));
  }

  // ── Provider error watch helper ─────────────────────────────
  // initState ya didChangeDependencies mein use karo:
  //   @override
  //   void didChangeDependencies() {
  //     super.didChangeDependencies();
  //     ErrorHandler.watchProvider(context, context.read<ProductProvider>().error);
  //   }
  static void watchProvider(BuildContext context, String? error) {
    if (error != null && error.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        show(context, error);
      });
    }
  }

  // ── Firestore error → user-friendly message ─────────────────
  static String _friendly(String raw) {
    if (raw.contains('permission-denied'))
      return 'Aapko yeh karne ki ijazat nahi hai.';
    if (raw.contains('not-found'))
      return 'Record nahi mila — delete ho chuka hoga.';
    if (raw.contains('unavailable') || raw.contains('network'))
      return 'Internet connection check karein.';
    if (raw.contains('deadline-exceeded') || raw.contains('timeout'))
      return 'Connection slow hai — dobara koshish karein.';
    if (raw.contains('already-exists'))
      return 'Yeh record pehle se exist karta hai.';
    if (raw.contains('unauthenticated'))
      return 'Session khatam — dobara login karein.';
    // Raw error se bhi zyada reveal na karo
    return 'Masla aa gaya. Dobara koshish karein.';
  }
}


// ═══════════════════════════════════════════════════════════════
//  FILE 2:  lib/widgets/offline_banner.dart  ← YEH FILE NAHI THI
//           Nai file hai — apne project mein banao
//
//  PART 6 — FIX:
//   FIX-6B: Offline hone pe user ko pata nahi chalta tha ke sale
//            "pending sync" hai. Ab ek banner show hota hai.
//
//   Use karo — main_layout.dart ya har screen ke top mein:
//     Column(children: [
//       const OfflineBanner(),
//       Expanded(child: actualScreen),
//     ])
//
//   pubspec.yaml mein add karo:
//     connectivity_plus: ^6.0.0
// ═══════════════════════════════════════════════════════════════

