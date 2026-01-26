import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      fontFamily: 'BeVietnamPro', // Khớp với index.html

      // Cấu hình Card chuẩn rounded-[2.5rem] (40px)
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
          side: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
        ),
        elevation: 0,
      ),

      // Cấu hình Text chuẩn Be Vietnam Pro
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white70),
        labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
      ),

      // Cấu hình Input (Tương đương Tailwind forms plugin)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.primary, width: 1),
        ),
      ),
    );
  }
}