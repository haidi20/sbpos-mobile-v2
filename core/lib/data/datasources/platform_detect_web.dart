import 'package:flutter/foundation.dart' show kIsWeb;

class PlatformDetect {
  static bool get isWeb => kIsWeb;
  static bool get isAndroid => false;
  static bool get isIOS => false;
  static bool get isFuchsia => false;
  static bool get isWindows => false;
  static bool get isLinux => false;
  static bool get isMacOS => false;
}
