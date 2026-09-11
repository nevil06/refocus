import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Deep Obsidian & Dark Navy Backgrounds
  static const Color background = Color(0xFF08090E);
  static const Color backgroundPrimary = Color(0xFF08090E);
  static const Color backgroundSecondary = Color(0xFF0E111A);
  static const Color surface = Color(0xFF141724);
  static const Color surfaceElevated = Color(0xFF1B2032);
  static const Color surfacePressed = Color(0xFF242A42);
  static const Color surfaceHover = Color(0xFF20263C);
  static const Color surfaceGlass = Color(0xCC141724);

  // Modern Borders & Dividers
  static const Color border = Color(0xFF23293D);
  static const Color borderLight = Color(0xFF2F3752);
  static const Color borderGlow = Color(0x408B5CF6);
  static const Color divider = Color(0xFF1E2438);

  // Premium Violet / Purple Primary & Accents
  static const Color primary = Color(0xFF8B5CF6); // Electric Violet
  static const Color primaryDark = Color(0xFF7C3AED);
  static const Color primaryLight = Color(0xFFA78BFA);
  static const Color primaryGlow = Color(0x338B5CF6);
  
  // Secondary & Pastel Accents
  static const Color secondary = Color(0xFFC4B5FD); // Soft Lavender
  static const Color accentLavender = Color(0xFFDDD6FE);
  static const Color accentCyan = Color(0xFF38BDF8);
  static const Color cyan = Color(0xFF38BDF8);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color amber = Color(0xFFF59E0B);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningGlow = Color(0x33F59E0B);
  static const Color red = Color(0xFFF43F5E);
  static const Color danger = Color(0xFFF43F5E);
  static const Color dangerGlow = Color(0x33F43F5E);
  static const Color redGlow = Color(0x33F43F5E);
  static const Color success = Color(0xFF10B981);
  static const Color successGlow = Color(0x3310B981);

  // Text Hierarchies
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
}

class AppGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGlowGradient = LinearGradient(
    colors: [Color(0xFFA78BFA), Color(0xFF7C3AED)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1B2032), Color(0xFF141724)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0x338B5CF6), Color(0x106366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGlow = LinearGradient(
    colors: [Color(0x1F8B5CF6), Color(0x05141724)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const SweepGradient timerRingGradient = SweepGradient(
    colors: [
      Color(0xFF6366F1),
      Color(0xFF8B5CF6),
      Color(0xFFA78BFA),
      Color(0xFFC4B5FD),
      Color(0xFF8B5CF6),
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );
}

class AppShadows {
  static const BoxShadow primaryGlow = BoxShadow(
    color: Color(0x408B5CF6),
    blurRadius: 18,
    spreadRadius: 1,
  );

  static const BoxShadow subtleGlow = BoxShadow(
    color: Color(0x258B5CF6),
    blurRadius: 12,
    spreadRadius: 0,
  );

  static BoxShadow cardShadow = BoxShadow(
    color: Colors.black.withOpacity(0.35),
    blurRadius: 14,
    offset: const Offset(0, 6),
  );

  static BoxShadow elevatedShadow = BoxShadow(
    color: Colors.black.withOpacity(0.5),
    blurRadius: 24,
    offset: const Offset(0, 8),
  );
}

class AppTheme {
  static ThemeData get darkTheme {
    final baseTextTheme = Typography.material2021().white;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        onPrimary: Colors.white,
        onSecondary: AppColors.background,
        onSurface: AppColors.textPrimary,
        error: AppColors.danger,
      ),
      textTheme: GoogleFonts.interTextTheme(baseTextTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontSize: 38,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontSize: 30,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        displaySmall: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        headlineLarge: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: GoogleFonts.inter(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: GoogleFonts.inter(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.normal,
        ),
        labelLarge: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: GoogleFonts.inter(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(
          color: AppColors.textMuted,
          fontSize: 14,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 24,
      ),
    );
  }
}
