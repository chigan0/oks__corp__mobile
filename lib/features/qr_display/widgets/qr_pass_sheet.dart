import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_fonts.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../entities/construction_object/model/construction_object.dart';
import '../../../shared/ui/bottom_sheets/app_bottom_sheet_shell.dart';
import '../../../shared/ui/bottom_sheets/sheet_icon_button.dart';
import '../../../shared/ui/skeleton/qr_pass_skeleton.dart';
import '../../qr_generation/api/qr_generation_api.dart';
import '../../qr_generation/qr_generation_notifier.dart';
import 'object_select_sheet.dart';

class QrPassSheet extends StatelessWidget {
  const QrPassSheet({
    super.key,
    required this.object,
    required this.isKz,
    required this.onBack,
    required this.onClose,
  });

  final ConstructionObject object;
  final bool isKz;
  final VoidCallback onBack;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<QrGenerationNotifier>(
      create: (ctx) => QrGenerationNotifier(
        api: ctx.read<QrGenerationApi>(),
        facilityUuid: object.id,
      ),
      child: _QrPassSheetBody(object: object, isKz: isKz, onBack: onBack, onClose: onClose),
    );
  }
}

class _QrPassSheetBody extends StatelessWidget {
  const _QrPassSheetBody({
    required this.object,
    required this.isKz,
    required this.onBack,
    required this.onClose,
  });

  final ConstructionObject object;
  final bool isKz;
  final VoidCallback onBack;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<QrGenerationNotifier>();
    final title = isKz ? 'Сіздің пропуск' : 'Ваш пропуск';
    final subtitle = isKz
        ? 'Бұл "${object.name}" объектісіне пропуск'
        : 'Это ваш пропуск на объект "${object.name}"';

    return AppBottomSheetShell(
      title: title,
      onClose: onClose,
      expandBody: true,
      leading: SheetIconButton(
        icon: Icons.arrow_back,
        onPressed: onBack,
      ),
      child: switch (notifier.status) {
        QrGenerationStatus.loading => const QrPassSkeleton(),
        QrGenerationStatus.error => _ErrorState(
            error: notifier.error,
            isKz: isKz,
            onRetry: notifier.generate,
          ),
        QrGenerationStatus.active => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(
                data: notifier.code ?? '',
                version: QrVersions.auto,
                size: _QrPassSheetBody._qrSize,
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
                _countdownLabel(isKz, notifier.remainingSeconds),
                textAlign: TextAlign.center,
                style: AppTypography.qrPassHint.copyWith(color: AppColors.grey600),
              ),
            ],
          ),
      },
    );
  }

  static const _qrSize = 296.0;

  String _countdownLabel(bool isKz, int seconds) {
    final m = seconds ~/ 60;
    final s = (seconds % 60).toString().padLeft(2, '0');
    final time = '$m:$s';
    return isKz ? 'Жаңарту: $time' : 'Обновится через: $time';
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.isKz, required this.onRetry});

  final QrGenerationException? error;
  final bool isKz;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final message = error?.message ??
        (isKz ? 'QR-кодты алу мүмкін болмады' : 'Не удалось получить QR-код');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: AppColors.red,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.priority_high, color: Colors.white, size: 36),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: AppFonts.manrope,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        YellowActionButton(
          label: isKz ? 'Қайталау' : 'Повторить',
          onPressed: onRetry,
          expand: false,
        ),
      ],
    );
  }
}
