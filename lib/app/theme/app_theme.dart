import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_fonts.dart';
import 'app_radius.dart';

abstract final class AppTheme {
  static const fontFamily = AppFonts.manrope;

  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary: AppColors.navy,
      secondary: AppColors.yellow,
      surface: AppColors.surface,
      error: AppColors.red,
      onPrimary: Colors.white,
      onSecondary: AppColors.navyDark,
      onSurface: AppColors.textPrimary,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: fontFamily,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.cardBorder,
        thickness: 1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.navyDark,
        contentTextStyle: manropeTextStyle(
          fontSize: 14,
          fontWeight: AppFontWeight.semiBold,
          color: Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );

    return base.copyWith(
      textTheme: _textTheme,
      primaryTextTheme: _textTheme,
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: manropeTextStyle(
          fontSize: 14,
          fontWeight: AppFontWeight.semiBold,
          color: AppColors.textPrimary,
        ),
        floatingLabelStyle: manropeTextStyle(
          fontSize: 14,
          fontWeight: AppFontWeight.semiBold,
          color: AppColors.textPrimary,
        ),
        hintStyle: manropeTextStyle(
          fontSize: 16,
          fontWeight: AppFontWeight.regular,
          color: AppColors.grey600,
        ),
      ),
    );
  }

  static final TextTheme _textTheme = TextTheme(
    displayLarge: manropeTextStyle(fontSize: 24, fontWeight: AppFontWeight.bold),
    displayMedium: manropeTextStyle(fontSize: 22, fontWeight: AppFontWeight.semiBold),
    displaySmall: manropeTextStyle(fontSize: 20, fontWeight: AppFontWeight.semiBold),
    headlineMedium: manropeTextStyle(fontSize: 18, fontWeight: AppFontWeight.semiBold),
    titleLarge: manropeTextStyle(fontSize: 16, fontWeight: AppFontWeight.semiBold),
    titleMedium: manropeTextStyle(fontSize: 14, fontWeight: AppFontWeight.semiBold),
    bodyLarge: manropeTextStyle(fontSize: 16, fontWeight: AppFontWeight.regular),
    bodyMedium: manropeTextStyle(fontSize: 14, fontWeight: AppFontWeight.regular),
    bodySmall: manropeTextStyle(fontSize: 12, fontWeight: AppFontWeight.regular),
    labelLarge: manropeTextStyle(fontSize: 14, fontWeight: AppFontWeight.semiBold),
  );
}
