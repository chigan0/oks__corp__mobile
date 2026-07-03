import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

/// Figma trailing toolbar button: 42×42 white circle with soft shadow.
class SheetIconButton extends StatelessWidget {
  const SheetIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  static const _size = 42.0;
  static const _iconSize = 28.0;

  static final _buttonShadow = BoxShadow(
    color: Colors.black.withValues(alpha: 0.15),
    blurRadius: 20,
    spreadRadius: 1,
    offset: const Offset(0, 8),
  );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 0,
      clipBehavior: Clip.none,
      child: Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surface,
          boxShadow: [_buttonShadow],
        ),
        clipBehavior: Clip.none,
        child: Material(
          color: Colors.transparent,
          elevation: 0,
          clipBehavior: Clip.none,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Icon(icon, size: _iconSize, color: AppColors.grey950),
          ),
        ),
      ),
    );
  }
}
