import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import 'app_skeleton.dart';

class DetailInfoPanelSkeleton extends StatelessWidget {
  const DetailInfoPanelSkeleton({super.key, this.rowCount = 5});

  final int rowCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < rowCount; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.lg),
            const _DetailRowSkeleton(),
          ],
        ],
      ),
    );
  }
}

class _DetailRowSkeleton extends StatelessWidget {
  const _DetailRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppSkeleton(width: 110, height: 14, borderRadius: 6),
        AppSkeleton(width: 130, height: 14, borderRadius: 6),
      ],
    );
  }
}
