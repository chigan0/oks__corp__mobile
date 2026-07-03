import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import 'skeleton/detail_info_panel_skeleton.dart';

/// Grouped detail rows inside a single grey card (Figma «Детальная»).
class DetailInfoPanel extends StatelessWidget {
  const DetailInfoPanel({
    super.key,
    required this.children,
    this.isLoading = false,
    this.skeletonRowCount = 5,
  });

  final List<Widget> children;
  final bool isLoading;
  final int skeletonRowCount;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return DetailInfoPanelSkeleton(rowCount: skeletonRowCount);
    }

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
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.lg),
            children[i],
          ],
        ],
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  const DetailRow({
    super.key,
    required this.label,
    this.value,
    this.valueWidget,
  });

  final String label;
  final String? value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('$label:', style: AppTypography.detailLabel),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: valueWidget ??
              Text(
                value ?? '',
                textAlign: TextAlign.right,
                style: AppTypography.detailValue,
              ),
        ),
      ],
    );
  }
}
