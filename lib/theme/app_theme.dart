// lib/theme/app_theme.dart
// SceneFlow - Design system and theme

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Background
  static const Color bg = Color(0xFF050505);
  static const Color surface = Color(0xFF131313);
  static const Color surfaceAlt = Color(0xFF1A1A1A);
  static const Color card = Color(0xFF1C1B1B);
  static const Color cardAlt = Color(0xFF20201F);

  // Accent - Gold/Amber
  static const Color gold = Color(0xFFFFBF00);
  static const Color goldLight = Color(0xFFFFE2AB);
  static const Color goldFaint = Color(0xFFFFDFA0);

  // Accent - Teal
  static const Color teal = Color(0xFF76D6D5);

  // Text
  static const Color textPrimary = Color(0xFFE5E2E1);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  // Status Colors
  static const Color statusDone = Color(0xFF76D6D5); // teal
  static const Color statusInProgress = Color(0xFFFFE2AB); // gold light
  static const Color statusDrafting = Color(0xFF353535);

  static const Color statusCompleted = Color(0xFF34D399); // emerald
  static const Color statusPreProd = Color(0xFF60A5FA); // blue
  static const Color statusInProd = Color(0xFFFFDFA0); // gold faint

  // Borders
  static const Color border = Color(0x1AFFFFFF); // white 10%
  static const Color borderSubtle = Color(0x0DFFFFFF); // white 5%
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        secondary: AppColors.teal,
        surface: AppColors.surface,
        onPrimary: Color(0xFF402D00),
        onSecondary: Colors.black,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        bodyMedium: GoogleFonts.inter(
          color: AppColors.textPrimary,
        ),
        labelSmall: GoogleFonts.inter(
          color: AppColors.textMuted,
          letterSpacing: 1.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface.withValues(alpha: 0.85),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.goldLight,
          fontWeight: FontWeight.w700,
          fontSize: 16,
          letterSpacing: 3,
        ),
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardAlt,
        selectedItemColor: AppColors.goldLight,
        unselectedItemColor: AppColors.textMuted,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceAlt,
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
          borderSide: const BorderSide(color: AppColors.teal),
        ),
        hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
        labelStyle: GoogleFonts.inter(color: AppColors.textSecondary),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.04),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.05),
        labelStyle: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),
      dividerColor: AppColors.border,
      useMaterial3: true,
    );
  }
}

// Glassmorphism decoration helper
BoxDecoration glassDecoration({
  double radius = 16,
  Color borderColor = AppColors.borderSubtle,
  Color bgColor = const Color(0x0AFFFFFF),
}) {
  return BoxDecoration(
    color: bgColor,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: borderColor),
  );
}
