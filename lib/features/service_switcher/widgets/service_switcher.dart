import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../entities/service_type/model/service_type.dart';
import '../../../shared/constants/app_assets.dart';
import '../../../shared/ui/app_asset_icon.dart';

class ServiceSwitcher extends StatelessWidget {
  const ServiceSwitcher({
    super.key,
    required this.selected,
    required this.availableRoles,
    required this.onChanged,
    this.craneIconColor,
  });

  final ServiceType selected;
  final List<ServiceType> availableRoles;
  final ValueChanged<ServiceType> onChanged;
  final Color? craneIconColor;

  /// Figma spec: 55×55. Slightly scaled for touch, kept close to design.
  static const buttonSize = 58.0;
  static const _gap = 12.0;
  static const _iconSize = 24.0;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final role in availableRoles) ...[
            if (role != availableRoles.first) const SizedBox(width: _gap),
            SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: _ServiceToggleButton(
                asset: role == ServiceType.worker
                    ? AppAssets.crane
                    : AppAssets.barrier,
                iconSize: _iconSize,
                iconColor:
                    role == ServiceType.worker ? craneIconColor : null,
                selected: selected == role,
                onTap: () => onChanged(role),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ServiceToggleButton extends StatelessWidget {
  const _ServiceToggleButton({
    required this.asset,
    required this.iconSize,
    required this.selected,
    required this.onTap,
    this.iconColor,
  });

  final String asset;
  final double iconSize;
  final bool selected;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: selected ? AppColors.serviceActive : AppColors.serviceInactive,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: selected ? AppColors.serviceActiveBorder : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          splashColor: AppColors.serviceActive.withValues(alpha: 0.4),
          highlightColor: AppColors.serviceActive.withValues(alpha: 0.2),
          child: Center(
            child: AppAssetIcon(
              asset: asset,
              size: iconSize,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
