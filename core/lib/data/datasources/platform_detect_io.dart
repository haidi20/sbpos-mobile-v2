import 'dart:io' show Platform;

class PlatformDetect {
  static bool get isWeb => false;
  static bool get isAndroid => Platform.isAndroid;
  static bool get isIOS => Platform.isIOS;
  static bool get isFuchsia => Platform.isFuchsia;
  static bool get isWindows => Platform.isWindows;
  static bool get isLinux => Platform.isLinux;
  static bool get isMacOS => Platform.isMacOS;
}
