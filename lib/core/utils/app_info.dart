import 'package:package_info_plus/package_info_plus.dart';

class AppInfo {
  static PackageInfo? _info;

  // main() mein call karo:
  //   await AppInfo.init();
  static Future<void> init() async {
    _info = await PackageInfo.fromPlatform();
  }

  static String get version    => _info?.version        ?? '1.0.0';
  static String get buildNumber => _info?.buildNumber   ?? '1';
  static String get appName    => _info?.appName        ?? 'StockPro';
  static String get fullVersion => 'v${version} (${buildNumber})';

// Settings screen mein use karo:
//   Text('${AppInfo.appName} ${AppInfo.fullVersion}')
// Yeh automatically pubspec.yaml ka version dikhayega
}
