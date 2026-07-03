import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../entities/construction_object/model/construction_object.dart';
import '../../../shared/ui/bottom_sheets/app_bottom_sheet_shell.dart';
import '../../../shared/ui/bottom_sheets/sheet_icon_button.dart';
import '../../../shared/ui/skeleton/qr_pass_skeleton.dart';

class QrPassSheet extends StatelessWidget {
  const QrPassSheet({
    super.key,
    required this.object,
    required this.isKz,
    required this.onBack,
    required this.onClose,
    this.isLoading = false,
  });

  final ConstructionObject object;
  final bool isKz;
  final VoidCallback onBack;
  final VoidCallback onClose;
  final bool isLoading;

  static const _qrSize = 296.0;

  @override
  Widget build(BuildContext context) {
    final title = isKz ? 'Сіздің пропуск' : 'Ваш пропуск';
    final subtitle = isKz
        ? 'Бұл "${object.name}" объектісіне пропуск'
        : 'Это ваш пропуск на объект "${object.name}"';
    final hint = isKz ? 'Оны күзетшіге көрсетіңіз' : 'Покажите его охраннику';

    return AppBottomSheetShell(
      title: title,
      onClose: onClose,
      expandBody: true,
      leading: SheetIconButton(
        icon: Icons.arrow_back,
        onPressed: onBack,
      ),
      child: isLoading
          ? const QrPassSkeleton()
          : Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          QrImageView(
            data: object.qrPayload,
            version: QrVersions.auto,
            size: _qrSize,
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTypography.qrPassLine,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            hint,
            textAlign: TextAlign.center,
            style: AppTypography.qrPassHint,
          ),
        ],
      ),
    );
  }
}
