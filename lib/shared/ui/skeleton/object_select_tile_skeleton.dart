import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import 'app_skeleton.dart';

class ObjectSelectTileSkeleton extends StatelessWidget {
  const ObjectSelectTileSkeleton({super.key});

  static const _qrButtonSize = 44.0;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary50,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 14,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppSkeleton(width: 20, height: 20, borderRadius: 4),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppSkeleton(width: 150, height: 16, borderRadius: 6),
                  const SizedBox(height: AppSpacing.xs),
                  const AppSkeleton(width: 190, height: 14, borderRadius: 6),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const AppSkeleton(
              width: _qrButtonSize,
              height: _qrButtonSize,
              borderRadius: _qrButtonSize / 2,
            ),
          ],
        ),
      ),
    );
  }
}
