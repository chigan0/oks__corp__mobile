import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../entities/user_profile/model/user_profile.dart';
import '../../../shared/ui/bottom_sheets/app_bottom_sheet_shell.dart';
import '../../../shared/ui/document_tile.dart';

class ProfileSheet extends StatelessWidget {
  const ProfileSheet({
    super.key,
    required this.profile,
    required this.isKz,
    required this.onClose,
  });

  final UserProfile profile;
  final bool isKz;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final phoneLabel = isKz ? 'Телефон нөмірі' : 'Номер телефона';
    final docsLabel = isKz ? 'Сіздің құжаттарыңыз' : 'Ваши документы';

    return AppBottomSheetShell(
      title: isKz ? 'Жеке кабинет' : 'Личный кабинет',
      onClose: onClose,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfilePhoneField(label: phoneLabel, phone: profile.phone),
          const SizedBox(height: AppSpacing.xl),
          Text(docsLabel, style: AppTypography.profileSectionTitle),
          const SizedBox(height: AppSpacing.lg),
          Column(
            children: [
              for (var i = 0; i < profile.documents.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.sm),
                DocumentTile(
                  fileName: profile.documents[i].fileName,
                  uploadedAt: profile.documents[i].uploadedAt,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfilePhoneField extends StatelessWidget {
  const _ProfilePhoneField({
    required this.label,
    required this.phone,
  });

  final String label;
  final String phone;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.grey300),
          ),
          child: Text(phone, style: AppTypography.profilePhoneValue),
        ),
        Positioned(
          left: 10.5,
          top: -8,
          child: Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(label, style: AppTypography.profilePhoneLabel),
          ),
        ),
      ],
    );
  }
}
