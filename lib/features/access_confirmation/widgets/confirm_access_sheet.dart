import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../entities/worker/model/scanned_worker.dart';
import '../../../shared/constants/app_assets.dart';
import '../../../shared/ui/app_asset_icon.dart';
import '../../../shared/ui/bottom_sheets/app_bottom_sheet_shell.dart';

class ConfirmAccessSheet extends StatelessWidget {
  const ConfirmAccessSheet({
    super.key,
    required this.worker,
    required this.onGrant,
    required this.onDeny,
  });

  final ScannedWorker worker;
  final VoidCallback onGrant;
  final VoidCallback onDeny;

  @override
  Widget build(BuildContext context) {
    return AppBottomSheetShell(
      title: 'Подтвердите допуск',
      onClose: () {},
      showCloseButton: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAssetIcon(
                asset: AppAssets.profile,
                size: 24,
                fallbackIcon: Icons.badge_outlined,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  worker.fullName,
                  style: AppTypography.confirmWorkerName,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoRow(label: 'ТОО:', value: worker.company),
          _InfoRow(label: 'ИИН:', value: worker.iin),
          _InfoRow(label: 'Номер:', value: worker.phone),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDeny,
                  icon: const Icon(Icons.close, size: 20),
                  label: const Text('Недопуск'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.red,
                    side: const BorderSide(color: AppColors.red),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: 10,
                    ),
                    textStyle: AppTypography.confirmButton.copyWith(
                      color: AppColors.red,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onGrant,
                  icon: const Icon(Icons.check, size: 20),
                  label: const Text('Допуск'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.greenButton,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: 10,
                    ),
                    textStyle: AppTypography.confirmButton.copyWith(
                      color: Colors.white,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: AppTypography.confirmInfoLabel),
          ),
          Text(value, style: AppTypography.confirmInfoValue),
        ],
      ),
    );
  }
}
