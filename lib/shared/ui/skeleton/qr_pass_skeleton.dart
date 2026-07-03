import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import 'app_skeleton.dart';

class QrPassSkeleton extends StatelessWidget {
  const QrPassSkeleton({super.key});

  static const _qrSize = 296.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppSkeleton(
          width: _qrSize,
          height: _qrSize,
          borderRadius: 12,
        ),
        const SizedBox(height: AppSpacing.lg),
        const AppSkeleton(width: 260, height: 16, borderRadius: 6),
        const SizedBox(height: AppSpacing.xs),
        const AppSkeleton(width: 180, height: 16, borderRadius: 6),
      ],
    );
  }
}
