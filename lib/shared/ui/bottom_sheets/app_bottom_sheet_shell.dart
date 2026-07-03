import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import 'sheet_icon_button.dart';

/// Standardized visual wrapper for modal bottom sheet content (Figma Sheet).
class AppBottomSheetShell extends StatelessWidget {
  const AppBottomSheetShell({
    super.key,
    required this.title,
    required this.onClose,
    required this.child,
    this.subtitle,
    this.leading,
    this.showCloseButton = true,
    this.expandBody = false,
  });

  final String title;
  final VoidCallback onClose;
  final Widget child;
  final String? subtitle;
  final Widget? leading;
  final bool showCloseButton;
  final bool expandBody;

  static const _headerSideExtent = 42.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheetTop),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 37.5,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: expandBody ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                children: [
                  const SizedBox(height: 5),
                  Center(
                    child: Container(
                      width: 36,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.grey300,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: _headerSideExtent,
                          ),
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: AppTypography.sheetTitle,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            leading ??
                                const SizedBox(
                                  width: _headerSideExtent,
                                  height: _headerSideExtent,
                                ),
                            if (showCloseButton)
                              SheetIconButton(
                                icon: Icons.close,
                                onPressed: onClose,
                              )
                            else
                              const SizedBox(
                                width: _headerSideExtent,
                                height: _headerSideExtent,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: Text(
                        subtitle!,
                        textAlign: TextAlign.center,
                        style: AppTypography.sheetSubtitle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (expandBody)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: child,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: child,
              ),
          ],
        ),
      ),
    );
  }
}
