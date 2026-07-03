import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_scanner.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/constants/app_assets.dart';
import '../../../shared/ui/app_asset_icon.dart';

/// Top scanner toolbar: object label + trailing close (Figma Frame 24 / 0:506).
class ScannerHeader extends StatelessWidget {
  const ScannerHeader({
    super.key,
    required this.title,
    required this.closeButton,
  });

  final String title;
  final Widget closeButton;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppScanner.headerHorizontalPadding,
        ),
        child: SizedBox(
          height: AppScanner.headerHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppAssetIcon(
                    asset: AppAssets.crane,
                    size: AppScanner.headerIconSize,
                    color: AppColors.background,
                    fallbackIcon: Icons.construction,
                  ),
                  const SizedBox(width: AppScanner.headerIconGap),
                  Text(title, style: AppTypography.scannerHeaderTitle),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: closeButton,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
