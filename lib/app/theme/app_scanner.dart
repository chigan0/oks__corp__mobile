import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppScanner {
  static const viewfinderSize = 199.0;
  static const viewfinderCornerRadius = 14.0;
  static const cornerColor = AppColors.yellow;
  static const cornerArm = 23.0;
  static const cornerStroke = 4.0;

  static const overlayGradientCenterYFactor = 365 / 568;
  static const overlayGradientRadiusFactor = 0.92;

  static const overlayGradientStops = <double>[
    0.01443,
    0.50722,
    0.75361,
    0.8768,
    0.9384,
    1.0,
  ];

  static const overlayGradientColors = <Color>[
    Color(0x00FFFFFF),
    Color(0x40828282),
    Color(0x60434343),
    Color(0x70242424),
    Color(0x78141414),
    Color(0x80050505),
  ];


  static const headerHeight = 42.0;
  static const headerHorizontalPadding = 16.0;
  static const headerIconGap = 4.0;
  static const headerIconSize = 16.0;


  static const headerToScannerGap = 36.0;
  static const hintLineHeight = 20.0;
  static const hintToViewfinderGap = 24.0;
  static const contentBottomPadding = 50.0;

  static const closeButtonSize = 42.0;
  static const closeIconSize = 28.0;
  static const closeButtonShadowBlur = 8.15;
  static const closeButtonShadowOpacity = 0.12;
}
