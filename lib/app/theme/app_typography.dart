import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_fonts.dart';

abstract final class AppTypography {
  static TextStyle get screenTitle => manropeTextStyle(
        fontSize: 20,
        fontWeight: AppFontWeight.semiBold,
        height: 20 / 20,
        color: AppColors.grey950,
      );

  static TextStyle get screenTitlePrimary => manropeTextStyle(
        fontSize: 20,
        fontWeight: AppFontWeight.semiBold,
        height: 20 / 20,
        color: AppColors.primary950,
      );

  static TextStyle get screenHint => manropeTextStyle(
        fontSize: 14,
        fontWeight: AppFontWeight.regular,
        height: 20 / 14,
        color: AppColors.grey800,
      );

  static TextStyle get tabLabel => manropeTextStyle(
        fontSize: 14,
        fontWeight: AppFontWeight.semiBold,
        height: 18 / 14,
        color: AppColors.grey950,
      );

  static TextStyle get tabLabelActive => manropeTextStyle(
        fontSize: 14,
        fontWeight: AppFontWeight.semiBold,
        height: 18 / 14,
        color: Colors.black,
      );

  static TextStyle get badgeLabel => manropeTextStyle(
        fontSize: 12,
        fontWeight: AppFontWeight.semiBold,
        height: 16 / 12,
      );

  static TextStyle get bottomBarAction => manropeTextStyle(
        fontSize: 18,
        fontWeight: AppFontWeight.semiBold,
        height: 26 / 18,
        color: Colors.black,
      );

  static TextStyle get sheetTitle => manropeTextStyle(
        fontSize: 22,
        fontWeight: AppFontWeight.semiBold,
        height: 1.0,
        color: AppColors.grey950,
      );

  static TextStyle get sheetSubtitle => manropeTextStyle(
        fontSize: 14,
        fontWeight: AppFontWeight.regular,
        height: 20 / 14,
        color: AppColors.grey800,
      );

  static TextStyle get detailLabel => manropeTextStyle(
        fontSize: 14,
        fontWeight: AppFontWeight.semiBold,
        height: 1.0,
        color: AppColors.grey950,
      );

  static TextStyle get detailValue => manropeTextStyle(
        fontSize: 14,
        fontWeight: AppFontWeight.regular,
        height: 1.0,
        color: AppColors.grey950,
      );

  static TextStyle get objectCardTitle => manropeTextStyle(
        fontSize: 16,
        fontWeight: AppFontWeight.semiBold,
        height: 20 / 16,
        color: AppColors.primary950,
      );

  static TextStyle get objectCardAddress => manropeTextStyle(
        fontSize: 14,
        fontWeight: AppFontWeight.regular,
        height: 1.0,
        color: AppColors.grey600,
      );

  static TextStyle get objectSelectTitle => manropeTextStyle(
        fontSize: 16,
        fontWeight: AppFontWeight.semiBold,
        height: 20 / 16,
        color: AppColors.grey950,
      );

  static TextStyle get objectSelectAddress => manropeTextStyle(
        fontSize: 14,
        fontWeight: AppFontWeight.regular,
        height: 1.0,
        color: AppColors.grey600,
      );

  static TextStyle get qrPassLine => manropeTextStyle(
        fontSize: 16,
        fontWeight: AppFontWeight.semiBold,
        height: 24 / 16,
        color: AppColors.grey700,
      );

  static TextStyle get qrPassHint => manropeTextStyle(
        fontSize: 16,
        fontWeight: AppFontWeight.semiBold,
        height: 24 / 16,
        color: AppColors.grey950,
      );

  static TextStyle get profileSectionTitle => manropeTextStyle(
        fontSize: 16,
        fontWeight: AppFontWeight.semiBold,
        height: 20 / 16,
        color: AppColors.grey950,
      );

  static TextStyle get profilePhoneLabel => manropeTextStyle(
        fontSize: 12,
        fontWeight: AppFontWeight.medium,
        height: 1.25,
        color: AppColors.grey500,
      );

  static TextStyle get profilePhoneValue => manropeTextStyle(
        fontSize: 14,
        fontWeight: AppFontWeight.semiBold,
        height: 20 / 14,
        color: AppColors.grey500,
      );

  static TextStyle get documentFileName => manropeTextStyle(
        fontSize: 14,
        fontWeight: AppFontWeight.semiBold,
        height: 1.0,
        color: AppColors.primary950,
      );

  static TextStyle get documentDate => manropeTextStyle(
        fontSize: 12,
        fontWeight: AppFontWeight.regular,
        height: 1.0,
        color: AppColors.grey600,
      );

  static TextStyle get languageOption => manropeTextStyle(
        fontSize: 16,
        fontWeight: AppFontWeight.semiBold,
        height: 26 / 16,
        color: AppColors.grey950,
      );

  static TextStyle get scannerHint => manropeTextStyle(
        fontSize: 16,
        fontWeight: AppFontWeight.bold,
        height: 20 / 16,
        color: AppColors.background,
      );

  static TextStyle get scannerHeaderTitle => manropeTextStyle(
        fontSize: 12,
        fontWeight: AppFontWeight.bold,
        height: 20 / 12,
        color: AppColors.background,
      );

  static TextStyle get confirmWorkerName => manropeTextStyle(
        fontSize: 18,
        fontWeight: AppFontWeight.semiBold,
        height: 22 / 18,
        color: AppColors.grey950,
      );

  static TextStyle get confirmInfoLabel => manropeTextStyle(
        fontSize: 16,
        fontWeight: AppFontWeight.semiBold,
        height: 1.0,
        color: AppColors.grey950,
      );

  static TextStyle get confirmInfoValue => manropeTextStyle(
        fontSize: 16,
        fontWeight: AppFontWeight.regular,
        height: 22 / 16,
        color: AppColors.grey950,
      );

  static TextStyle get confirmButton => manropeTextStyle(
        fontSize: 18,
        fontWeight: AppFontWeight.semiBold,
        height: 24 / 18,
      );
}
