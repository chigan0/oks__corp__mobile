import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_fonts.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';

/// Full-screen alert shown when /validate returns 404 (code invalid, used or expired).
class AccessDeniedScreen extends StatelessWidget {
  const AccessDeniedScreen({
    super.key,
    required this.message,
    required this.onDismiss,
  });

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.red,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.block, color: Colors.white, size: 96),
              const SizedBox(height: AppSpacing.xxl),
              const Text(
                'Допуск запрещён',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppFonts.manrope,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppFonts.manrope,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onDismiss,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.red,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: const Text('Понятно'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
