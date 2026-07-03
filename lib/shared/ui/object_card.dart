import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../entities/construction_object/model/construction_object.dart';
import '../../shared/constants/app_assets.dart';
import '../../shared/ui/app_asset_icon.dart';
import '../../shared/ui/status_badge.dart';

class ObjectCard extends StatelessWidget {
  const ObjectCard({
    super.key,
    required this.object,
    required this.isKz,
    required this.onTap,
    this.iconColor,
  });

  final ConstructionObject object;
  final bool isKz;
  final VoidCallback onTap;

  /// When null, the SVG renders with its default asset color (main screen).
  final Color? iconColor;

  static const _iconTextGap = 8.0;
  static const _titleToAddressGap = 8.0;
  static const _addressToStatusGap = 8.0;
  static const _textToChevronGap = 8.0;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.grey100,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 14,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppAssetIcon(
                asset: AppAssets.crane,
                size: 20,
                color: iconColor,
                fallbackIcon: Icons.construction,
              ),
              const SizedBox(width: _iconTextGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(object.name, style: AppTypography.objectCardTitle),
                    const SizedBox(height: _titleToAddressGap),
                    Text(
                      object.address,
                      style: AppTypography.objectCardAddress,
                    ),
                    const SizedBox(height: _addressToStatusGap),
                    StatusBadge(
                      status: object.accessStatus,
                      isKz: isKz,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: _textToChevronGap),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.grey200,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: AppColors.grey950,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
