import 'package:flutter/material.dart';

import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import 'app_skeleton.dart';

/// Placeholder for the "Мои сервисы" body while the user's role is being
/// resolved (future: role lookup by phone number).
class RoleSelectionSkeleton extends StatelessWidget {
  const RoleSelectionSkeleton({super.key});

  static const _switcherSize = 58.0;
  static const _switcherGap = 12.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              AppSkeleton(
                width: _switcherSize,
                height: _switcherSize,
                borderRadius: AppRadius.lg,
              ),
              SizedBox(width: _switcherGap),
              AppSkeleton(
                width: _switcherSize,
                height: _switcherSize,
                borderRadius: AppRadius.lg,
              ),
            ],
          ),
        ),
        const Spacer(flex: 2),
        const Center(
          child: AppSkeleton(width: 64, height: 64, borderRadius: AppRadius.md),
        ),
        const SizedBox(height: AppSpacing.xxl),
        const Center(
          child: AppSkeleton(width: 200, height: 22, borderRadius: 6),
        ),
        const SizedBox(height: AppSpacing.md),
        const Center(
          child: AppSkeleton(width: 260, height: 14, borderRadius: 6),
        ),
        const SizedBox(height: AppSpacing.xs),
        const Center(
          child: AppSkeleton(width: 210, height: 14, borderRadius: 6),
        ),
        const Spacer(flex: 3),
        const AppSkeleton(height: 52, borderRadius: AppRadius.pill),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}
