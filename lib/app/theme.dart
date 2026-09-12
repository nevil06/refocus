import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// =============================================================================
// NEO-BRUTALISM SHAPE SYSTEM (Sharp, confident, 0-4px corners)
// =============================================================================
class AppRadius {
  static const double none = 0.0;
  static const double small = 2.0;       // Badges, micro tags
  static const double medium = 3.0;      // Cards, list tiles, text fields
  static const double large = 4.0;       // Containers, surface blocks
  static const double extraLarge = 4.0;  // Dialogs & bottom sheets
  static const double full = 4.0;        // Neo-brutalist replacement for pills (sharp 4px)

  static const BorderRadius smallRadius = BorderRadius.all(Radius.circular(small));
  static const BorderRadius mediumRadius = BorderRadius.all(Radius.circular(medium));
  static const BorderRadius largeRadius = BorderRadius.all(Radius.circular(large));
  static const BorderRadius extraLargeRadius = BorderRadius.all(Radius.circular(extraLarge));
  static const BorderRadius fullRadius = BorderRadius.all(Radius.circular(full));
}

// =============================================================================
// NEO-BRUTALISM BORDERS & STROKES (Thick, solid, high-contrast)
// =============================================================================
class AppBorders {
  static const double thin = 1.5;
  static const double normal = 2.0;
  static const double standard = 2.0;
  static const double thick = 3.0;

  static const Border solidNormal = Border.fromBorderSide(BorderSide(color: AppColors.border, width: normal));
  static const Border solidHighContrast = Border.fromBorderSide(BorderSide(color: Color(0xFF2E384D), width: normal));
  static const Border solidBlack = Border.fromBorderSide(BorderSide(color: Color(0xFF000000), width: normal));
  static const Border solidMint = Border.fromBorderSide(BorderSide(color: AppColors.neonMint, width: normal));
  static const Border solidCyan = Border.fromBorderSide(BorderSide(color: AppColors.electricCyan, width: normal));
  static const Border solidAmber = Border.fromBorderSide(BorderSide(color: AppColors.warmAmber, width: normal));
  static const Border solidCoral = Border.fromBorderSide(BorderSide(color: AppColors.coralRed, width: normal));
}

// =============================================================================
// COLOR PALETTE — OBSIDIAN BASE WITH BOLD SCLERA & SATURATED ACCENTS
// =============================================================================
class AppColors {
  // Deep Obsidian & Dark Navy Backgrounds (Brand Identity)
  static const Color deepObsidian = Color(0xFF090A0F);
  static const Color background = Color(0xFF090A0F);
  static const Color backgroundPrimary = Color(0xFF090A0F);
  static const Color backgroundSecondary = Color(0xFF0E111A);

  // Flat Solid Surface Containers (NO Frosted Glass / NO Blur)
  static const Color surfaceContainerLowest = Color(0xFF090A0F); // Base canvas
  static const Color surfaceContainerLow = Color(0xFF0E111A);    // Low tier
  static const Color surfaceContainer = Color(0xFF12151E);       // Card fill
  static const Color surface = Color(0xFF12151E);
  static const Color surfaceGlass = Color(0xFF12151E);           // Flat fill replacement
  static const Color surfaceContainerHigh = Color(0xFF1A1F2C);   // Elevated blocks
  static const Color surfaceElevated = Color(0xFF1A1F2C);
  static const Color surfaceContainerHighest = Color(0xFF222838);// Floating blocks
  static const Color surfacePressed = Color(0xFF283044);
  static const Color surfaceHover = Color(0xFF1E2434);

  // Key Brand Accent Colors (Bold saturated blocks)
  static const Color neonMint = Color(0xFF00E699);      // Primary Accent
  static const Color emerald = Color(0xFF00E699);
  static const Color accentMint = Color(0xFF00E699);
  static const Color electricCyan = Color(0xFF38BDF8);   // Secondary Accent
  static const Color cyan = Color(0xFF38BDF8);
  static const Color accentCyan = Color(0xFF38BDF8);
  static const Color royalIndigo = Color(0xFF818CF8);    // Tertiary Accent
  static const Color indigo = Color(0xFF818CF8);
  static const Color warmAmber = Color(0xFFFBBF24);      // Warning & Streak Flame
  static const Color amber = Color(0xFFFBBF24);
  static const Color coralRed = Color(0xFFF43F5E);       // Error & Locked Mode
  static const Color danger = Color(0xFFF43F5E);
  static const Color red = Color(0xFFF43F5E);
  static const Color success = Color(0xFF00E699);

  // Electric Violet / Purple
  static const Color primary = Color(0xFF8B5CF6);
  static const Color primaryDark = Color(0xFF7C3AED);
  static const Color primaryLight = Color(0xFFA78BFA);
  static const Color primaryGlow = Color(0xFF8B5CF6);
  static const Color secondary = Color(0xFFC4B5FD);
  static const Color accent = Color(0xFF6366F1);
  static const Color accentLavender = Color(0xFFDDD6FE);
  static const Color purple = Color(0xFF8B5CF6);

  // Neo-Brutalism Solid Borders & Dividers
  static const Color border = Color(0xFF2E384D);
  static const Color borderPrimary = Color(0xFF2E384D);
  static const Color borderLight = Color(0xFF3B4863);
  static const Color borderGlow = Color(0xFF8B5CF6);
  static const Color divider = Color(0xFF23293D);

  // Shadows
  static const Color shadowHard = Color(0xFF000000);
  static const Color shadowColor = Color(0xFF000000);
  static const Color warningGlow = Color(0xFFFBBF24);
  static const Color dangerGlow = Color(0xFFF43F5E);
  static const Color redGlow = Color(0xFFF43F5E);
  static const Color successGlow = Color(0xFF00E699);
  static const Color mintGlow = Color(0xFF00E699);
  static const Color cyanGlow = Color(0xFF38BDF8);

  // Text Hierarchies (High Contrast)
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
}

// =============================================================================
// NEO-BRUTALISM FLAT GRADIENTS (Flat solid colors, no soft transitions)
// =============================================================================
class AppGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF8B5CF6)],
  );

  static const LinearGradient mintGradient = LinearGradient(
    colors: [Color(0xFF00E699), Color(0xFF00E699)],
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF38BDF8), Color(0xFF38BDF8)],
  );

  static const LinearGradient primaryGlowGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF8B5CF6)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF161A26), Color(0xFF161A26)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF161A26), Color(0xFF161A26)],
  );

  static const LinearGradient surfaceGlow = LinearGradient(
    colors: [Color(0xFF12151E), Color(0xFF12151E)],
  );

  static const SweepGradient timerRingGradient = SweepGradient(
    colors: [
      Color(0xFF00E699),
      Color(0xFF00E699),
    ],
  );
}

// =============================================================================
// NEO-BRUTALISM HARD OFFSET SHADOWS (ZERO BLUR)
// =============================================================================
class AppShadows {
  // Signature Neo-Brutalist Hard Offset Shadows
  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0xFF000000),
    offset: Offset(4, 4),
    blurRadius: 0,
  );

  static const BoxShadow elevatedShadow = BoxShadow(
    color: Color(0xFF000000),
    offset: Offset(5, 5),
    blurRadius: 0,
  );

  static const BoxShadow buttonShadow = BoxShadow(
    color: Color(0xFF000000),
    offset: Offset(3, 3),
    blurRadius: 0,
  );

  static const BoxShadow primaryGlow = BoxShadow(
    color: AppColors.primary,
    offset: Offset(3, 3),
    blurRadius: 0,
  );

  static const BoxShadow subtleGlow = BoxShadow(
    color: Color(0xFF000000),
    offset: Offset(2, 2),
    blurRadius: 0,
  );

  static const BoxShadow mintHardShadow = BoxShadow(
    color: AppColors.neonMint,
    offset: Offset(3, 3),
    blurRadius: 0,
  );

  static const BoxShadow cyanHardShadow = BoxShadow(
    color: AppColors.electricCyan,
    offset: Offset(3, 3),
    blurRadius: 0,
  );

  static const BoxShadow amberHardShadow = BoxShadow(
    color: AppColors.warmAmber,
    offset: Offset(3, 3),
    blurRadius: 0,
  );

  static const BoxShadow dangerHardShadow = BoxShadow(
    color: AppColors.coralRed,
    offset: Offset(3, 3),
    blurRadius: 0,
  );
}

// =============================================================================
// NEO-BRUTALISM THEME DEFINITION
// =============================================================================
class AppTheme {
  static ThemeData get darkTheme {
    final baseTextTheme = Typography.material2021().white;

    const brutalColorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF4C1D95),
      onPrimaryContainer: Color(0xFFDDD6FE),
      secondary: AppColors.electricCyan,
      onSecondary: Color(0xFF090A0F),
      secondaryContainer: Color(0xFF0C3547),
      onSecondaryContainer: Color(0xFFBAE6FD),
      tertiary: AppColors.royalIndigo,
      onTertiary: Color(0xFF090A0F),
      tertiaryContainer: Color(0xFF2A2E5E),
      onTertiaryContainer: Color(0xFFC7D2FE),
      error: AppColors.coralRed,
      onError: Colors.white,
      errorContainer: Color(0xFF4C0B18),
      onErrorContainer: Color(0xFFFECDD3),
      surface: AppColors.surfaceContainer,
      onSurface: AppColors.textPrimary,
      surfaceContainerLowest: AppColors.surfaceContainerLowest,
      surfaceContainerLow: AppColors.surfaceContainerLow,
      surfaceContainer: AppColors.surfaceContainer,
      surfaceContainerHigh: AppColors.surfaceContainerHigh,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
      outline: AppColors.border,
      outlineVariant: AppColors.divider,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.deepObsidian,
      colorScheme: brutalColorScheme,
      // Chunky Neo-Brutalist Typography (heavy weights: 700/800/900)
      textTheme: GoogleFonts.interTextTheme(baseTextTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontSize: 40,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
          height: 1.1,
        ),
        displayMedium: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          height: 1.15,
        ),
        displaySmall: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontSize: 26,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
          height: 1.2,
        ),
        headlineLarge: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
        headlineMedium: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        headlineSmall: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
        titleMedium: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
        titleSmall: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
        bodyLarge: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
          height: 1.4,
        ),
        bodyMedium: GoogleFonts.inter(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.4,
        ),
        bodySmall: GoogleFonts.inter(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
          height: 1.35,
        ),
        labelLarge: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
        labelMedium: GoogleFonts.inter(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
        labelSmall: GoogleFonts.inter(
          color: AppColors.textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.largeRadius,
          side: const BorderSide(color: AppColors.border, width: 2.0),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceContainerHigh,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.extraLargeRadius,
          side: const BorderSide(color: AppColors.border, width: 2.5),
        ),
        titleTextStyle: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        contentTextStyle: GoogleFonts.inter(
          color: AppColors.textSecondary,
          fontSize: 14,
          height: 1.45,
        ),
      ),
      // Neo-Brutalist Switch Styling
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF090A0F);
          }
          return AppColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.neonMint;
          }
          return AppColors.surfaceContainerHigh;
        }),
        trackOutlineColor: const WidgetStatePropertyAll(Color(0xFF000000)),
        trackOutlineWidth: const WidgetStatePropertyAll(2.0),
        thumbIcon: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Icon(Icons.check_rounded, color: Color(0xFF090A0F), size: 14);
          }
          return null;
        }),
      ),
      // Neo-Brutalist Sharp Chips
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainer,
        selectedColor: AppColors.neonMint,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.largeRadius,
          side: const BorderSide(color: AppColors.border, width: 2.0),
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      // Neo-Brutalist Sharp Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonMint,
          foregroundColor: const Color(0xFF090A0F),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.largeRadius,
            side: const BorderSide(color: Color(0xFF000000), width: 2.0),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border, width: 2.0),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.largeRadius,
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: AppRadius.largeRadius,
          borderSide: const BorderSide(color: AppColors.border, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.largeRadius,
          borderSide: const BorderSide(color: AppColors.border, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.largeRadius,
          borderSide: const BorderSide(color: AppColors.neonMint, width: 2.5),
        ),
        hintStyle: GoogleFonts.inter(
          color: AppColors.textMuted,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 2,
        space: 24,
      ),
    );
  }
}
