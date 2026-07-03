import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../features/qr_display/widgets/object_select_sheet.dart';
import '../../shared/constants/app_assets.dart';
import '../../shared/ui/app_asset_icon.dart';

class FloatingBottomBar extends StatelessWidget {
  const FloatingBottomBar({
    super.key,
    required this.qrLabel,
    required this.onProfile,
    required this.onShowQr,
    required this.onLanguage,
    this.expandQrButton = true,
  });

  final String qrLabel;
  final VoidCallback onProfile;
  final VoidCallback onShowQr;
  final VoidCallback onLanguage;
  final bool expandQrButton;

  static const _sideIconSize = 24.0;
  static const _sidePadding = 10.0;

  @override
  Widget build(BuildContext context) {
    final profileButton = _SideIconButton(
      onPressed: onProfile,
      child: AppAssetIcon(asset: AppAssets.profile, size: _sideIconSize),
    );
    final languageButton = _SideIconButton(
      onPressed: onLanguage,
      child: const Icon(
        Icons.translate,
        size: _sideIconSize,
        color: AppColors.grey950,
      ),
    );
    final qrButton = YellowActionButton(
      label: qrLabel,
      iconAsset: AppAssets.qr,
      expand: expandQrButton,
      onPressed: onShowQr,
    );

    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.background,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              offset: const Offset(0, -6),
              blurRadius: 12,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            AppSpacing.bottomBarBottomInset,
          ),
          child: expandQrButton
              ? Row(
                  children: [
                    profileButton,
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(child: qrButton),
                    const SizedBox(width: AppSpacing.lg),
                    languageButton,
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    profileButton,
                    qrButton,
                    languageButton,
                  ],
                ),
        ),
      ),
    );
  }
}

class _SideIconButton extends StatelessWidget {
  const _SideIconButton({
    required this.onPressed,
    required this.child,
  });

  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.grey200,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(FloatingBottomBar._sidePadding),
          child: SizedBox(
            width: FloatingBottomBar._sideIconSize,
            height: FloatingBottomBar._sideIconSize,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
