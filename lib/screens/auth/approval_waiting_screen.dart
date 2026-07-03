import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_fonts.dart';
import '../../app/theme/app_spacing.dart';
import '../../features/auth/auth_notifier.dart';
import '../../shared/api/api_config.dart';
import '../../shared/constants/app_assets.dart';
import '../../shared/ui/app_asset_icon.dart';
import '../../shared/ui/app_primary_button.dart';
import '../../shared/ui/bottom_sheets/sheet_icon_button.dart';
import '../../shared/ui/oks_header.dart';
import '../../shared/ui/spinning_asset.dart';

class ApprovalWaitingScreen extends StatefulWidget {
  const ApprovalWaitingScreen({super.key});

  @override
  State<ApprovalWaitingScreen> createState() => _ApprovalWaitingScreenState();
}

class _ApprovalWaitingScreenState extends State<ApprovalWaitingScreen> {
  Timer? _pollTimer;

  static const _illustrationWidth = 220.0;
  static const _illustrationAspectRatio = 170 / 234;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startPolling();
      _pollOnce();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(ApiConfig.approvalPollInterval, (_) {
      _pollOnce();
    });
  }

  Future<void> _pollOnce() async {
    final authNotifier = context.read<AuthNotifier>();

    if (authNotifier.shouldStopPolling) {
      _pollTimer?.cancel();
    }

    if (authNotifier.isWaitingForApproval) {
      await authNotifier.pollApprovalStatus();
    }

    if (!mounted) return;

    if (authNotifier.isAuthenticated) {
      _pollTimer?.cancel();
      context.go('/roles');
    }
  }

  void _goBack() {
    _pollTimer?.cancel();
    context.read<AuthNotifier>().resetApprovalFlow();
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = context.watch<AuthNotifier>();
    final phone = authNotifier.phone ?? '';
    final isDenied = authNotifier.isDenied;
    final errorMessage = authNotifier.errorMessage;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.screenHeaderTopInset,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          'Авторизация',
                          textAlign: TextAlign.center,
                          style: manropeTextStyle(
                            fontSize: 20,
                            fontWeight: AppFontWeight.semiBold,
                            color: AppColors.grey950,
                            height: 1.0,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SheetIconButton(
                              icon: Icons.chevron_left,
                              onPressed: _goBack,
                            ),
                            const OksGroupLogo(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    isDenied
                        ? 'К сожалению, вам отказано в доступе. Обратитесь в OKS Pulse'
                        : 'Пожалуйста, подождите подтверждения входа от OKS Group',
                    textAlign: TextAlign.center,
                    style: manropeTextStyle(
                      fontSize: 16,
                      fontWeight: AppFontWeight.regular,
                      color: AppColors.grey950,
                      height: 1.4,
                    ),
                  ),
                  if (!isDenied) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      phone,
                      textAlign: TextAlign.center,
                      style: manropeTextStyle(
                        fontSize: 15,
                        fontWeight: AppFontWeight.regular,
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                  const Spacer(flex: 2),
                  Center(
                    child: SizedBox(
                      width: _illustrationWidth,
                      height: _illustrationWidth * _illustrationAspectRatio,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: SvgPicture.asset(
                              AppAssets.builder,
                              fit: BoxFit.contain,
                            ),
                          ),
                          if (isDenied)
                            const Positioned(
                              top: -8,
                              right: 4,
                              child: AppAssetIcon(
                                asset: AppAssets.warning,
                                size: 52,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),
                  if (errorMessage != null && !isDenied) ...[
                    Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: manropeTextStyle(
                        fontSize: 14,
                        fontWeight: AppFontWeight.regular,
                        color: AppColors.red,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  if (isDenied)
                    AppPrimaryButton(
                      label: 'Вернуться назад',
                      onPressed: _goBack,
                    ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
            if (!isDenied)
              const Center(
                child: SpinningAsset(asset: AppAssets.load, size: 56),
              ),
          ],
        ),
      ),
    );
  }
}
