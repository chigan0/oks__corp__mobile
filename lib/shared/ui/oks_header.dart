import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_fonts.dart';
import '../../app/theme/app_spacing.dart';

/// Branded OKS Group wordmark (Figma header logo).
class OksGroupLogo extends StatelessWidget {
  const OksGroupLogo({
    super.key,
    this.fontSize = 15,
    this.color = AppColors.oksGroupNavy,
    this.onTap,
  });

  final double fontSize;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final baseStyle = manropeTextStyle(
      fontSize: fontSize,
      color: color,
      height: 1.0,
    );

    final logo = RichText(
      text: TextSpan(
        style: baseStyle,
        children: [
          TextSpan(
            text: 'OKS ',
            style: manropeTextStyle(
              fontSize: fontSize,
              fontWeight: AppFontWeight.extraBold,
              color: color,
              height: 1.0,
            ),
          ),
          TextSpan(
            text: 'Group',
            style: manropeTextStyle(
              fontSize: fontSize,
              fontWeight: AppFontWeight.medium,
              color: color,
              height: 1.0,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return logo;
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: logo,
    );
  }
}

class OksHeader extends StatelessWidget {
  const OksHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.titleStyle,
    this.onLogoTap,
    this.trailing,
  });

  final String title;
  final Widget? subtitle;
  final TextStyle? titleStyle;
  final VoidCallback? onLogoTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.screenHeaderTopInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                title,
                style: titleStyle ??
                    manropeTextStyle(
                      fontSize: 20,
                      fontWeight: AppFontWeight.semiBold,
                      color: const Color(0xFF030712),
                      height: 1.0,
                    ),
              ),
            ),
            trailing ?? OksGroupLogo(onTap: onLogoTap),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.sm),
          subtitle!,
        ],
      ],
      ),
    );
  }
}
