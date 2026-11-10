import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF00897B); // Teal
  static const Color primaryLight = Color(0xFFE0F2F1); // Light teal background
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color divider = Color(0xFFEEEEEE);
  static const Color statusCompleted = Color(0xFF2E7D32); // Dark green
  static const Color statusCancelled = Color(0xFFD32F2F); // Red
  static const Color statusInProgress = Color(0xFF1565C0); // Blue
  static const Color statusScheduled = Color(0xFF757575); // Grey
  static const Color statusUnknown = Color(0xFF757575);
  static const Color bottomNavSelected = Color(0xFF00897B);
  static const Color bottomNavUnselected = Color(0xFF757575);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.bottomNavSelected,
        unselectedItemColor: AppColors.bottomNavUnselected,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 0,
      ),
    );
  }
}
