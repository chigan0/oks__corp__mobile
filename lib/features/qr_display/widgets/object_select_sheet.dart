import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../entities/construction_object/model/construction_object.dart';
import '../../../shared/constants/app_assets.dart';
import '../../../shared/ui/app_asset_icon.dart';
import '../../../shared/ui/bottom_sheets/app_bottom_sheet_shell.dart';
import '../../../shared/ui/skeleton/object_select_tile_skeleton.dart';

class YellowActionButton extends StatelessWidget {
  const YellowActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.iconAsset,
    this.expand = true,
    this.fontSize = 18,
  });

  final String label;
  final VoidCallback onPressed;
  final String? iconAsset;
  final bool expand;
  final double fontSize;

  static const _iconSize = 24.0;
  static const _horizontalPadding = 14.0;
  static const _verticalPadding = 9.0;

  @override
  Widget build(BuildContext context) {
    final child = Material(
      color: AppColors.yellow,
      borderRadius: BorderRadius.circular(AppRadius.bottomBarQr),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.bottomBarQr),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _horizontalPadding,
            vertical: _verticalPadding,
          ),
          child: Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (iconAsset != null) ...[
                AppAssetIcon(asset: iconAsset!, size: _iconSize),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                label,
                style: AppTypography.bottomBarAction.copyWith(
                  fontSize: fontSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: child) : child;
  }
}

class ObjectSelectSheet extends StatelessWidget {
  const ObjectSelectSheet({
    super.key,
    required this.objects,
    required this.isKz,
    required this.onClose,
    required this.onSelect,
  });

  final List<ConstructionObject> objects;
  final bool isKz;
  final VoidCallback onClose;
  final ValueChanged<ConstructionObject> onSelect;

  @override
  Widget build(BuildContext context) {
    return AppBottomSheetShell(
      title: isKz ? 'Нысанды таңдаңыз' : 'Выберите объект',
      subtitle: isKz
          ? 'Қай нысанға пропуск керек?'
          : 'К какому объекту вам нужен пропуск?',
      onClose: onClose,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < objects.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.lg),
            ObjectSelectTile(
              object: objects[i],
              onTap: () => onSelect(objects[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class ObjectSelectTile extends StatelessWidget {
  const ObjectSelectTile({
    super.key,
    required this.object,
    required this.onTap,
    this.isLoading = false,
  });

  final ConstructionObject object;
  final VoidCallback onTap;
  final bool isLoading;

  static const _qrButtonSize = 44.0;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const ObjectSelectTileSkeleton();
    }

    return Material(
      color: AppColors.primary50,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
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
                color: const Color(0xFF9296E3),
                fallbackIcon: Icons.construction,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(object.name, style: AppTypography.objectSelectTitle),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      object.address,
                      style: AppTypography.objectSelectAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                width: _qrButtonSize,
                height: _qrButtonSize,
                decoration: const BoxDecoration(
                  color: AppColors.yellow,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: AppAssetIcon(asset: AppAssets.qr, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
