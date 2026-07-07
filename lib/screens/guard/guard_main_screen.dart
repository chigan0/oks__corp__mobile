import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../entities/construction_object/repository/object_repository.dart';
import '../../features/qr_display/widgets/object_select_sheet.dart';
import '../../shared/constants/app_assets.dart';
import '../../shared/ui/app_asset_icon.dart';
import '../../shared/ui/oks_header.dart';

class GuardMainScreen extends StatelessWidget {
  const GuardMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final guardObject = ObjectRepository.instance.localObjects.first;
    final objectLabel = 'Объект \u201c${guardObject.name}\u201d';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/roles');
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OksHeader(
                  title: 'Охрана (КПП)',
                  onLogoTap: () => context.go('/roles'),
                ),
                const SizedBox(height: 200),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppAssetIcon(
                      asset: AppAssets.crane,
                      size: 50,
                      color: const Color(0xFF9296E3),
                      fallbackIcon: Icons.construction,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        objectLabel,
                        style: AppTypography.screenTitlePrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: 
                  Text(
                    'Сканируйте пропуск в виде QR и разрешайте или блокируйте пропуск на объект',
                    textAlign : TextAlign.center,
                    style: AppTypography.screenHint.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 48.0),
                  child: YellowActionButton(
                    label: 'Отсканировать пропуск',
                    iconAsset: AppAssets.qr,
                    onPressed: () => context.push('/guard/scanner'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
