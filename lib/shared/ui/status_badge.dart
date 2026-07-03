import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../entities/construction_object/model/access_status.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
    required this.isKz,
  });

  final AccessStatus status;
  final bool isKz;

  @override
  Widget build(BuildContext context) {
    final granted = status.isGranted;
    final fg = granted ? AppColors.greenText : AppColors.redText;
    final icon = granted ? Icons.check_circle_outline : Icons.cancel_outlined;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: fg),
        const SizedBox(width: 4),
        Text(
          status.labelRu(isKz),
          style: AppTypography.badgeLabel.copyWith(color: fg),
        ),
      ],
    );
  }
}
