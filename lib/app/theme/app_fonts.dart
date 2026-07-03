import 'package:flutter/material.dart';

abstract final class AppFonts {
  static const manrope = 'Manrope';
}

/// Matches Figma Manrope styles (Regular / Medium / Semi Bold / Bold).
abstract final class AppFontWeight {
  static const regular = FontWeight.w400;
  static const medium = FontWeight.w500;
  static const semiBold = FontWeight.w600;
  static const bold = FontWeight.w700;
  static const extraBold = FontWeight.w800;
}

/// Manrope [TextStyle] with an explicit variable-font weight axis.
TextStyle manropeTextStyle({
  required double fontSize,
  FontWeight fontWeight = AppFontWeight.regular,
  double? height,
  Color? color,
  double? letterSpacing,
}) {
  return TextStyle(
    fontFamily: AppFonts.manrope,
    fontSize: fontSize,
    fontWeight: fontWeight,
    fontVariations: [FontVariation.weight(fontWeight.value.toDouble())],
    height: height,
    color: color,
    letterSpacing: letterSpacing,
  );
}
