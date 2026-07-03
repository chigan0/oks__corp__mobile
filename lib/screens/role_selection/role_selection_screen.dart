import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_fonts.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../entities/service_type/model/service_type.dart';
import '../../features/auth/auth_notifier.dart';
import '../../features/profile/api/profile_api.dart';
import '../../features/profile/widgets/account_profile_sheet.dart';
import '../../features/service_switcher/widgets/service_switcher.dart';
import '../../shared/constants/app_assets.dart';
import '../../shared/ui/app_asset_icon.dart';
import '../../shared/ui/bottom_sheet_launchers.dart';
import '../../shared/ui/app_primary_button.dart';
import '../../shared/ui/oks_header.dart';
import '../../shared/ui/skeleton/role_selection_skeleton.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  ServiceType? _selected;
  List<ServiceType> _availableRoles = const [];
  bool _isResolvingRole = true;
  String? _roleErrorMessage;

  @override
  void initState() {
    super.initState();
    _resolveRole();
  }

  Future<void> _resolveRole() async {
    setState(() {
      _isResolvingRole = true;
      _roleErrorMessage = null;
    });

    try {
      final profile = await context.read<ProfileApi>().fetchProfile();
      final roles = profile.assignedServiceTypes;

      if (!mounted) return;

      if (roles.isEmpty) {
        setState(() {
          _availableRoles = const [];
          _selected = null;
          _roleErrorMessage =
              'Для вашего аккаунта не назначена роль. Обратитесь в OKS Pulse.';
        });
        return;
      }

      setState(() {
        _availableRoles = roles;
        _selected = roles.first;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _availableRoles = const [];
        _selected = null;
        _roleErrorMessage = 'Не удалось загрузить роль пользователя.';
      });
    } finally {
      if (mounted) {
        setState(() => _isResolvingRole = false);
      }
    }
  }

  String get _heroAsset {
    return switch (_selected) {
      ServiceType.worker => AppAssets.crane,
      ServiceType.guard => AppAssets.barrier,
      null => AppAssets.crane,
    };
  }

  void _proceed() {
    final selected = _selected;
    if (selected == null) return;
    context.go(selected.route);
  }

  void _openProfile() {
    showAppModalBottomSheet<void>(
      context,
      AccountProfileSheet(onClose: () => Navigator.of(context).pop()),
      initialChildSize: 0.4,
    );
  }

  Future<void> _confirmLogout() async {
    final authNotifier = context.read<AuthNotifier>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _LogoutDialog(),
    );

    if (confirmed == true) {
      await authNotifier.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.surface,
              AppColors.gradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.lg),
                OksHeader(
                  title: 'Мои сервисы',
                  titleStyle: manropeTextStyle(
                    fontSize: 22,
                    fontWeight: AppFontWeight.semiBold,
                    color: AppColors.serviceIcon,
                    height: 1.2,
                  ),
                  onLogoTap: () => context.go('/roles'),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Expanded(
                  child: _isResolvingRole
                      ? const RoleSelectionSkeleton()
                      : _roleErrorMessage != null
                          ? _RoleErrorState(message: _roleErrorMessage!)
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (_availableRoles.length > 1)
                                  ServiceSwitcher(
                                    selected: _selected!,
                                    availableRoles: _availableRoles,
                                    onChanged: (type) =>
                                        setState(() => _selected = type),
                                    craneIconColor: const Color(0xFF111827),
                                  ),
                                const Spacer(flex: 2),
                                AppAssetIcon(
                                  asset: _heroAsset,
                                  size: 64,
                                  color: _selected == ServiceType.worker
                                      ? const Color(0xFF111827)
                                      : null,
                                ),
                                const SizedBox(height: AppSpacing.xxl),
                                Text(
                                  _selected!.title,
                                  textAlign: TextAlign.center,
                                  style: manropeTextStyle(
                                    fontSize: 22,
                                    fontWeight: AppFontWeight.semiBold,
                                    color: AppColors.serviceIcon,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.lg,
                                  ),
                                  child: Text(
                                    _selected!.description,
                                    textAlign: TextAlign.center,
                                    style: manropeTextStyle(
                                      fontSize: 15,
                                      height: 1.5,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ),
                                const Spacer(flex: 3),
                              ],
                            ),
                ),
                if (!_isResolvingRole) ...[
                  Row(
                    children: [
                      _CircleIconButton(
                        asset: AppAssets.profile,
                        onPressed: _openProfile,
                      ),
                      if (_selected != null) ...[
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AppPrimaryButton(
                            label: 'Перейти',
                            icon: Icons.arrow_upward,
                            onPressed: _proceed,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                      ] else
                        const Spacer(),
                      _CircleIconButton(
                        asset: AppAssets.logout,
                        onPressed: _confirmLogout,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleErrorState extends StatelessWidget {
  const _RoleErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(flex: 2),
        Text(
          message,
          textAlign: TextAlign.center,
          style: manropeTextStyle(
            fontSize: 16,
            fontWeight: AppFontWeight.regular,
            color: AppColors.red,
            height: 1.4,
          ),
        ),
        const Spacer(flex: 3),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.asset, required this.onPressed});

  final String asset;
  final VoidCallback onPressed;

  static const _size = 52.0;
  static const _iconSize = 24.0;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: _size,
          height: _size,
          child: Center(
            child: AppAssetIcon(asset: asset, size: _iconSize),
          ),
        ),
      ),
    );
  }
}

class _LogoutDialog extends StatelessWidget {
  const _LogoutDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Выход',
              style: manropeTextStyle(
                fontSize: 18,
                fontWeight: AppFontWeight.semiBold,
                color: AppColors.grey950,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Вы уверены, что хотите выйти из аккаунта?',
              textAlign: TextAlign.center,
              style: manropeTextStyle(
                fontSize: 14,
                fontWeight: AppFontWeight.regular,
                color: AppColors.grey600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.lg,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      side: const BorderSide(color: AppColors.grey300),
                      foregroundColor: AppColors.textPrimary,
                    ),
                    child: Text(
                      'Отмена',
                      style: manropeTextStyle(
                        fontSize: 16,
                        fontWeight: AppFontWeight.semiBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppPrimaryButton(
                    label: 'Выйти',
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
