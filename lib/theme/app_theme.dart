import 'package:flutter/material.dart';
import 'app_colors.dart';

const _poppins = 'Poppins';

class AppTheme {
  static const Color primaryColor = AppColors.accent;
  static const Color accentColor = AppColors.accentLight;
  static const Color backgroundColor = AppColors.bgDark;
  static const Color surfaceColor = AppColors.bgPanel;
  static const Color cardColor = AppColors.bgCard;
  static const Color textPrimary = AppColors.textMain;
  static const Color textMuted = AppColors.textMuted;
  static const Color borderColor = AppColors.border;
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color goldColor = Color(0xFFFFD700);

  static List<Color> getRatingGradient(double rating) {
    if (rating >= 8) return [const Color(0xFF4CAF50), const Color(0xFF2E7D32)];
    if (rating >= 6) return [const Color(0xFFFFC107), const Color(0xFFFF8F00)];
    if (rating >= 4) return [const Color(0xFFFF9800), const Color(0xFFE65100)];
    return [const Color(0xFFF44336), const Color(0xFFB71C1C)];
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.accent,
      scaffoldBackgroundColor: AppColors.bgDark,
      fontFamily: _poppins,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.accentLight,
        surface: AppColors.bgPanel,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgDark.withValues(alpha: 0.95),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: _poppins,
          color: AppColors.textMain,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
        iconTheme: const IconThemeData(color: AppColors.textMain),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgDark,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontFamily: _poppins,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: _poppins,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(fontFamily: _poppins, fontWeight: FontWeight.w800, fontSize: 28, color: AppColors.textMain),
        displayMedium: TextStyle(fontFamily: _poppins, fontWeight: FontWeight.w700, fontSize: 24, color: AppColors.textMain),
        headlineLarge: TextStyle(fontFamily: _poppins, fontWeight: FontWeight.w800, fontSize: 22, color: AppColors.textMain),
        headlineMedium: TextStyle(fontFamily: _poppins, fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.textMain),
        titleLarge: TextStyle(fontFamily: _poppins, fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textMain),
        titleMedium: TextStyle(fontFamily: _poppins, fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textMain),
        bodyLarge: TextStyle(fontFamily: _poppins, fontWeight: FontWeight.w400, fontSize: 16, color: AppColors.textMain),
        bodyMedium: TextStyle(fontFamily: _poppins, fontWeight: FontWeight.w400, fontSize: 14, color: AppColors.textMuted),
        bodySmall: TextStyle(fontFamily: _poppins, fontWeight: FontWeight.w400, fontSize: 12, color: AppColors.textMuted),
        labelLarge: TextStyle(fontFamily: _poppins, fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textMain),
        labelSmall: TextStyle(fontFamily: _poppins, fontWeight: FontWeight.w500, fontSize: 11, color: AppColors.textMuted),
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgPanel,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent),
        ),
        labelStyle: TextStyle(fontFamily: _poppins, color: AppColors.textMuted),
        hintStyle: TextStyle(fontFamily: _poppins, color: AppColors.textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: TextStyle(
            fontFamily: _poppins,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.bgPanel,
        contentTextStyle: TextStyle(color: AppColors.textMain),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.bgDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
