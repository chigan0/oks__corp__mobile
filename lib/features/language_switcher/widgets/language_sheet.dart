import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/ui/bottom_sheets/app_bottom_sheet_shell.dart';
import '../language_notifier.dart';

class LanguageSheet extends StatelessWidget {
  const LanguageSheet({
    super.key,
    required this.isKz,
    required this.selected,
    required this.onSelect,
    required this.onClose,
  });

  final bool isKz;
  final AppLanguage selected;
  final ValueChanged<AppLanguage> onSelect;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return AppBottomSheetShell(
      title: isKz ? 'Тілді таңдаңыз' : 'Выберите язык',
      onClose: onClose,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LanguageOptionTile(
            label: 'Русский',
            isSelected: selected == AppLanguage.ru,
            onTap: () => onSelect(AppLanguage.ru),
          ),
          const SizedBox(height: AppSpacing.sm),
          _LanguageOptionTile(
            label: 'Казакша',
            isSelected: selected == AppLanguage.kz,
            onTap: () => onSelect(AppLanguage.kz),
          ),
        ],
      ),
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  static const _radioSize = 18.0;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.grey100,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(label, style: AppTypography.languageOption),
              ),
              Container(
                width: _radioSize,
                height: _radioSize,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.grey400),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 0.5),
                    ),
                  ],
                ),
                child: isSelected
                    ? DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.primary600,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
