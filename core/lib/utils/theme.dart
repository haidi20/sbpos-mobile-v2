import 'package:flutter/material.dart';

class AppSetting {
  static const Color primaryColor = Color.fromRGBO(4, 122, 74, 1);
}

class AppColors {
  static const Color sbBlue = Color(0xFF1E40AF);
  static const Color sbLightBlue = Color(0xFF00A3E0);
  static const Color sbOrange = Color(0xFFF97316);
  static const Color sbGold = Color(0xFFFFB81C);
  static const Color sbBg = Color(0xFFF8FAFC);
  static const Color sbBlueDark = Color(0xFF003B73);
  static const Color sbGreen = Color(0xFF16A34A);
  static const Color sbGray = Color(0xFF4B5563);
  static const Color sbBlueGray = Color(0xFF1F2937);

  // gray
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
}

final ThemeData theme = ThemeData(
  useMaterial3: true, // Aktifkan Material Design 3 (default di Flutter ≥3.0)
  fontFamily: 'Poppins',
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.sbLightBlue, // Warna utama aplikasi
    primary: AppColors.sbBlue,
    secondary: AppColors.sbOrange, // Bisa disesuaikan
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
