import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_fonts.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../features/auth/auth_notifier.dart';
import '../../shared/ui/app_primary_button.dart';
import '../../shared/ui/oks_header.dart';
import '../../shared/utils/kz_phone_input_formatter.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  final _phoneFormatter = KzPhoneInputFormatter();

  bool _isPhoneValid = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_handlePhoneChanged);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_handlePhoneChanged);
    _phoneController.dispose();
    super.dispose();
  }

  void _handlePhoneChanged() {
    final digits = KzPhoneInputFormatter.digitsOnly(_phoneController.text);
    final isValid = digits.length == 10;
    if (isValid != _isPhoneValid) {
      setState(() => _isPhoneValid = isValid);
    }
  }

  String _formatLockCountdown(int secondsRemaining) {
    final minutes = (secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authNotifier = context.read<AuthNotifier>();
    if (authNotifier.isPhoneLocked) {
      return;
    }

    final phoneDigits = KzPhoneInputFormatter.digitsOnly(_phoneController.text);
    final phone =
        phoneDigits.length == 10 ? '+7$phoneDigits' : _phoneController.text.trim();

    try {
      await authNotifier.submitPhone(phone);
      if (!mounted) return;
      if (authNotifier.isWaitingForApproval) {
        context.push('/approval-waiting');
      } else {
        _showErrorSnackBar(
          authNotifier.errorMessage ?? 'Не удалось отправить запрос',
        );
      }
    } catch (_) {
      if (!mounted) return;
      _showErrorSnackBar(
        authNotifier.errorMessage ?? 'Не удалось отправить запрос',
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        content: Row(
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: manropeTextStyle(
                  fontSize: 14,
                  fontWeight: AppFontWeight.semiBold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = context.watch<AuthNotifier>();
    final isLoading = authNotifier.isSubmittingPhone;
    final isLocked = authNotifier.isPhoneLocked;
    final canSubmit = _isPhoneValid && !isLocked && !isLoading;

    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.grey300),
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.lg),
                const OksHeader(title: 'Авторизация'),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  'Пожалуйста, введите ваш номер телефона, чтобы продолжить',
                  style: manropeTextStyle(
                    fontSize: 16,
                    fontWeight: AppFontWeight.regular,
                    color: AppColors.grey950,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  enabled: !isLoading && !isLocked,
                  inputFormatters: [_phoneFormatter],
                  style: manropeTextStyle(
                    fontSize: 22,
                    fontWeight: AppFontWeight.medium,
                    color: AppColors.grey500,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Номер телефона',
                    border: fieldBorder,
                    enabledBorder: fieldBorder,
                    focusedBorder: fieldBorder.copyWith(
                      borderSide: const BorderSide(color: AppColors.primary950),
                    ),
                  ),
                  validator: (value) {
                    final digits = KzPhoneInputFormatter.digitsOnly(value ?? '');
                    if (digits.length != 10) {
                      return 'Введите номер телефона полностью';
                    }
                    return null;
                  },
                ),
                if (isLocked) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Превышено количество попыток входа. Попробуйте позже.',
                    style: manropeTextStyle(
                      fontSize: 14,
                      fontWeight: AppFontWeight.regular,
                      color: AppColors.red,
                      height: 1.4,
                    ),
                  ),
                  if (authNotifier.phoneLockSecondsRemaining != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _formatLockCountdown(
                        authNotifier.phoneLockSecondsRemaining!,
                      ),
                      style: manropeTextStyle(
                        fontSize: 14,
                        fontWeight: AppFontWeight.regular,
                        color: AppColors.red,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
                const Spacer(),
                AppPrimaryButton(
                  label: isLoading ? 'Отправка...' : 'Войти',
                  enabled: canSubmit,
                  onPressed: _continue,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
