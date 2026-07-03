import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_fonts.dart';
import '../../app/theme/app_spacing.dart';
import '../constants/app_assets.dart';
import 'app_asset_icon.dart';

/// Full-screen blocker shown when the device loses internet connectivity.
class OfflineBlockingOverlay extends StatelessWidget {
  const OfflineBlockingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: SafeArea(
        child: AbsorbPointer(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: AppAssetIcon(
                    asset: AppAssets.warning,
                    size: 56,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                Text(
                  'Нет подключения к интернету',
                  textAlign: TextAlign.center,
                  style: manropeTextStyle(
                    fontSize: 22,
                    fontWeight: AppFontWeight.semiBold,
                    color: AppColors.grey950,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Проверьте Wi‑Fi или мобильные данные. '
                  'Все сервисы и кнопки будут доступны после восстановления связи.',
                  textAlign: TextAlign.center,
                  style: manropeTextStyle(
                    fontSize: 16,
                    fontWeight: AppFontWeight.regular,
                    color: AppColors.grey600,
                    height: 1.45,
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

/// Wraps the app navigator and blocks interaction while offline.
class OfflineAppShell extends StatelessWidget {
  const OfflineAppShell({
    super.key,
    required this.isOffline,
    required this.child,
  });

  final bool isOffline;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        if (isOffline) const OfflineBlockingOverlay(),
      ],
    );
  }
}
