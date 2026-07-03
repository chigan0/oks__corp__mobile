import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';

class DocumentTile extends StatelessWidget {
  const DocumentTile({
    super.key,
    required this.fileName,
    required this.uploadedAt,
    this.onDownload,
  });

  final String fileName;
  final DateTime uploadedAt;
  final VoidCallback? onDownload;

  static const _downloadPadding = 9.0;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd.MM.yyyy HH:mm').format(uploadedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fileName, style: AppTypography.documentFileName),
                const SizedBox(height: AppSpacing.xs),
                Text(dateStr, style: AppTypography.documentDate),
              ],
            ),
          ),
          Material(
            color: AppColors.grey200,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onDownload ??
                  () {
                    debugPrint('Download: $fileName');
                  },
              customBorder: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(_downloadPadding),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: Icon(
                    Icons.download_outlined,
                    size: 16,
                    color: AppColors.grey950,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
