import 'package:core/core.dart';

/// Default SnackBar dengan konfigurasi dasar
SnackBar simpleSnackBar(
  String message, {
  Color? textColor,
  Color backgroundColor = Colors.black87,
  Duration duration = const Duration(seconds: 2),
  SnackBarBehavior behavior = SnackBarBehavior.floating,
  SnackBarAction? action,
  EdgeInsetsGeometry? margin,
  EdgeInsetsGeometry? padding,
  ShapeBorder? shape,
  double? elevation,
  TextAlign textAlign = TextAlign.center,
  TextStyle? textStyle,
}) {
  return SnackBar(
    content: Text(
      message,
      textAlign: textAlign,
      style: textStyle ??
          TextStyle(
            color: textColor ?? Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
    ),
    backgroundColor: backgroundColor,
    duration: duration,
    behavior: behavior,
    action: action,
    margin: margin ?? const EdgeInsets.all(16),
    padding:
        padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: shape ??
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
    elevation: elevation ?? 6,
  );
}

/// Success SnackBar – hijau, teks putih
SnackBar successSnackBar(String message, {Duration? duration}) {
  return simpleSnackBar(
    message,
    backgroundColor: Colors.green.shade600, // lebih konsisten
    textColor: Colors.white,
    duration: duration ?? const Duration(seconds: 2),
  );
}

/// ✅ Warning / Info SnackBar – KUNING LEMBUT (seperti Container info Anda)
SnackBar warningSnackBar(String message, {Duration? duration}) {
  return simpleSnackBar(
    message,
    backgroundColor: Colors.yellow.shade50, // latar belakang lembut
    textColor: Colors.yellow.shade900, // teks gelap agar kontras
    duration: duration ?? const Duration(seconds: 3),
  );
}

/// Error SnackBar – merah, teks putih
SnackBar errorSnackBar(String message, {Duration? duration}) {
  return simpleSnackBar(
    message,
    backgroundColor: Colors.red.shade600,
    textColor: Colors.white,
    duration: duration ?? const Duration(seconds: 3),
  );
}

/// Default SnackBar – abu-abu gelap, teks putih
SnackBar defaultSnackBar(String message, {Duration? duration}) {
  return simpleSnackBar(
    message,
    backgroundColor: Colors.grey.shade800,
    textColor: Colors.white,
    duration: duration ?? const Duration(seconds: 2),
  );
}

// =============== Helper untuk langsung tampilkan ===============

void showSimpleSnackBar(BuildContext context, String message,
    {Color? backgroundColor, Color? textColor}) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    simpleSnackBar(
      message,
      backgroundColor: backgroundColor ?? AppSetting.primaryColor,
      textColor: textColor,
    ),
  );
}

void showSuccessSnackBar(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(successSnackBar(message));
}

void showWarningSnackBar(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(warningSnackBar(message));
}

void showErrorSnackBar(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(errorSnackBar(message));
}

void showDefaultSnackBar(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(defaultSnackBar(message));
}
