import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.bottleGreen,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.bottleGreen,
          onPrimary: Colors.white,
          secondary: AppColors.cider,
          onSecondary: Colors.white,
          surface: AppColors.surface,
          onSurface: AppColors.ink,
          error: AppColors.danger,
          onError: Colors.white,
        );

    final body = GoogleFonts.sourceSans3TextTheme(
      ThemeData(brightness: Brightness.light, colorScheme: scheme).textTheme,
    );
    final text = body.copyWith(
      headlineLarge: GoogleFonts.fraunces(
        textStyle: body.headlineLarge,
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      headlineMedium: GoogleFonts.fraunces(
        textStyle: body.headlineMedium,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      headlineSmall: GoogleFonts.fraunces(
        textStyle: body.headlineSmall,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      titleLarge: GoogleFonts.fraunces(
        textStyle: body.titleLarge,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      titleMedium: GoogleFonts.sourceSans3(
        textStyle: body.titleMedium,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      titleSmall: GoogleFonts.sourceSans3(
        textStyle: body.titleSmall,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      bodyLarge: GoogleFonts.sourceSans3(
        textStyle: body.bodyLarge,
        fontSize: 18,
        height: 1.5,
        color: AppColors.ink,
      ),
      bodyMedium: GoogleFonts.sourceSans3(
        textStyle: body.bodyMedium,
        fontSize: 16,
        height: 1.5,
        color: AppColors.ink,
      ),
      bodySmall: GoogleFonts.sourceSans3(
        textStyle: body.bodySmall,
        fontSize: 14,
        height: 1.4,
        color: AppColors.inkMuted,
      ),
      labelLarge: GoogleFonts.sourceSans3(
        textStyle: body.labelLarge,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.paper,
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.paper,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: text.titleLarge,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          backgroundColor: AppColors.bottleGreen,
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          textStyle: GoogleFonts.sourceSans3(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: AppColors.bottleGreen,
          side: const BorderSide(color: AppColors.bottleGreen, width: 1.5),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          textStyle: GoogleFonts.sourceSans3(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: AppRadius.card,
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.card,
          borderSide: BorderSide(color: AppColors.line),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.card,
          borderSide: BorderSide(color: AppColors.bottleGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(color: AppColors.line),
        ),
      ),
    );
  }
}

