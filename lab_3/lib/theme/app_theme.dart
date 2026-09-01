import 'package:flutter/material.dart';

/// Icesi Beats color palette.
class AppColors {
  static const background = Color(0xFF121212);
  static const surface = Color(0xFF1E1E1E);
  static const field = Color(0xFF2A2A2A);
  static const green = Color(0xFF1DB954);
  static const border = Color(0xFF3E3E3E);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB3B3B3);
}

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Roboto',
    colorScheme: const ColorScheme.dark(
      primary: AppColors.green,
      onPrimary: Colors.black,
      surface: AppColors.background,
      onSurface: AppColors.textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
