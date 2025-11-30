import 'package:flutter/material.dart';

class AppSetting {
  static const Color primaryColor =
      Color.fromRGBO(4, 122, 74, 1); // Ganti dengan warna utama aplikasi Anda
}

class AppColors {
  static const Color sbBlue = Color(0xFF1E40AF);
  static const Color sbOrange = Color(0xFFF97316);
  static const Color sbBg = Color(0xFFF8FAFC);
  static const Color sbBlueDark = Color(0xFF003B73);
  static const Color sbGreen = Color(0xFF16A34A);
}

final ThemeData theme = ThemeData(
  useMaterial3: true, // Aktifkan Material Design 3 (default di Flutter ≥3.0)
  fontFamily: 'Poppins',
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppSetting.primaryColor, // Warna utama aplikasi
    primary: AppSetting.primaryColor,
    secondary: AppSetting.primaryColor, // Bisa disesuaikan
    surface: Colors.white, // Ganti background dengan surface
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.black,
    brightness: Brightness.light,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    elevation: 0,
    foregroundColor: Colors.white,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
        fontSize: 22.0,
        color: AppSetting.primaryColor), // headline1 → displayLarge
    headlineLarge: TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.w700,
      color: AppSetting.primaryColor,
    ), // headline2 → headlineLarge
    bodyLarge: TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w400,
      color: Colors.blueAccent,
    ), // bodyText1 → bodyLarge
  ),
  // Opsional: sesuaikan scaffold background
  scaffoldBackgroundColor: Colors.white,
);
