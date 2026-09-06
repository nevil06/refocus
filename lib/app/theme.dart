import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Minimalist, professional black-and-white palette.
///
/// Colors resolve at runtime from [AppColors.brightness], so the same field
/// names work in both light and dark mode. The app sets [brightness] from the
/// system setting (see main.dart), giving automatic light/dark theming without
/// rewriting every widget to a Theme lookup.
///
/// The design is intentionally monochrome: near-black and white with a scale of
/// greys. A single accent (near-black in light mode, near-white in dark mode)
/// keeps the UI calm and premium. A muted set of status colors (amber/red/green)
/// remains for streaks, warnings, and destructive actions.
class AppColors {
  static Brightness brightness = Brightness.dark;

  static bool get _dark => brightness == Brightness.dark;

  // Surfaces (greyscale)
  static Color get background => _dark ? const Color(0xFF0A0A0A) : const Color(0xFFFAFAFA);
  static Color get surface => _dark ? const Color(0xFF141414) : const Color(0xFFFFFFFF);
  static Color get surfaceElevated => _dark ? const Color(0xFF1C1C1C) : const Color(0xFFF2F2F2);
  static Color get surfaceHover => _dark ? const Color(0xFF262626) : const Color(0xFFEAEAEA);

  // Borders
  static Color get border => _dark ? const Color(0xFF242424) : const Color(0xFFE4E4E4);
  static Color get borderLight => _dark ? const Color(0xFF333333) : const Color(0xFFD4D4D4);

  // Accent: monochrome. High-contrast against the background.
  static Color get primary => _dark ? const Color(0xFFF5F5F5) : const Color(0xFF111111);
  static Color get primaryGlow =>
      _dark ? const Color(0x33FFFFFF) : const Color(0x22000000);
  // On-accent (text/icon that sits on top of primary-filled surfaces).
  static Color get onPrimary => _dark ? const Color(0xFF0A0A0A) : const Color(0xFFFFFFFF);

  // Kept for API compatibility; mapped into the monochrome scheme where used
  // for neutral emphasis, but real status colors below stay meaningful.
  static Color get cyan => _dark ? const Color(0xFFBFBFBF) : const Color(0xFF555555);
  static Color get teal => cyan;
  static Color get purple => primary;

  // Status colors (muted, used sparingly for meaning, not decoration).
  static Color get amber => _dark ? const Color(0xFFE0B341) : const Color(0xFFB8860B);
  static Color get green => _dark ? const Color(0xFF6FCF97) : const Color(0xFF2E7D5B);
  static Color get red => _dark ? const Color(0xFFF06B6B) : const Color(0xFFD23B3B);
  static Color get redGlow => _dark ? const Color(0x33F06B6B) : const Color(0x22D23B3B);

  // Text
  static Color get textPrimary => _dark ? const Color(0xFFF5F5F5) : const Color(0xFF121212);
  static Color get textSecondary => _dark ? const Color(0xFF9A9A9A) : const Color(0xFF5C5C5C);
  static Color get textMuted => _dark ? const Color(0xFF6A6A6A) : const Color(0xFF8C8C8C);
}

class AppTheme {
  static ThemeData get darkTheme => _build(Brightness.dark);
  static ThemeData get lightTheme => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    // Ensure AppColors resolves to the theme being built.
    AppColors.brightness = brightness;
    final isDark = brightness == Brightness.dark;

    final baseTextTheme =
        (isDark ? Typography.material2021().white : Typography.material2021().black);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.textSecondary,
        onSecondary: AppColors.onPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.red,
        onError: AppColors.onPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(baseTextTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontSize: 40,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        headlineLarge: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: GoogleFonts.inter(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: GoogleFonts.inter(
          color: AppColors.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        labelLarge: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 17),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(color: AppColors.borderLight, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.textPrimary),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(
          color: AppColors.textMuted,
          fontSize: 14,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 24,
      ),
    );
  }
}
