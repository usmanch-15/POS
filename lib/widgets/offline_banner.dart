import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  bool                 _isOffline = false;
  StreamSubscription?  _sub;

  @override
  void initState() {
    super.initState();
    // Current status check karo
    Connectivity().checkConnectivity().then(_updateStatus);
    // Changes listen karo
    _sub = Connectivity().onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(dynamic result) {
    // ConnectivityResult ya List<ConnectivityResult> handle karo
    bool offline;
    if (result is List) {
      offline = result.every((r) => r == ConnectivityResult.none);
    } else {
      offline = result == ConnectivityResult.none;
    }
    if (mounted) setState(() => _isOffline = offline);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOffline) return const SizedBox.shrink();

    return Material(
      color: Colors.orange.shade700,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: Row(children: [
            const Icon(Icons.cloud_off, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Offline mode — Sales local save ho rahi hain, internet wapas aane pe sync hogi',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
