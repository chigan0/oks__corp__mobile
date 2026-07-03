import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_fonts.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';

class DenialDialog extends StatelessWidget {
  const DenialDialog({
    super.key,
    required this.workerName,
    required this.onAccepted,
  });

  final String workerName;
  final VoidCallback onAccepted;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 36),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Недопуск',
              style: TextStyle(
                fontFamily: AppFonts.manrope,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '$workerName не допущен на объект',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppFonts.manrope,
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onAccepted,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                child: const Text('Принято'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
