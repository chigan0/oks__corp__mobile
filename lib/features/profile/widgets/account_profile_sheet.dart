import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/constants/app_assets.dart';
import '../../../shared/ui/bottom_sheets/app_bottom_sheet_shell.dart';
import '../../../shared/ui/spinning_asset.dart';
import '../api/profile_api.dart';
import '../model/account_profile.dart';

/// "Профиль" sheet on the "Мои сервисы" screen: welcome message + phone,
/// fetched live from GET /accounts/me/.
class AccountProfileSheet extends StatefulWidget {
  const AccountProfileSheet({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  State<AccountProfileSheet> createState() => _AccountProfileSheetState();
}

class _AccountProfileSheetState extends State<AccountProfileSheet> {
  late final Future<AccountProfile> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<ProfileApi>().fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheetShell(
      title: 'Профиль',
      onClose: widget.onClose,
      child: FutureBuilder<AccountProfile>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
              child: Center(
                child: SpinningAsset(asset: AppAssets.load, size: 48),
              ),
            );
          }

          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Не удалось загрузить профиль',
                    textAlign: TextAlign.center,
                    style: AppTypography.profileSectionTitle.copyWith(
                      color: AppColors.red,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SelectableText(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: AppTypography.profilePhoneLabel.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),
            );
          }

          final profile = snapshot.data!;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Добро пожаловать, ${profile.fullName}',
                textAlign: TextAlign.center,
                style: AppTypography.profileSectionTitle,
              ),
              const SizedBox(height: AppSpacing.xl),
              _PhoneField(label: 'Номер телефона', phone: profile.phone),
            ],
          );
        },
      ),
    );
  }
}

class _PhoneField extends StatelessWidget {
  const _PhoneField({required this.label, required this.phone});

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
