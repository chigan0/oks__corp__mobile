import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppAssetIcon extends StatelessWidget {
  const AppAssetIcon({
    super.key,
    required this.asset,
    this.size = 24,
    this.color,
    this.fallbackIcon = Icons.image_outlined,
  });

  final String asset;
  final double size;
  final Color? color;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    if (asset.endsWith('.svg')) {
      return SvgPicture.asset(
        asset,
        width: size,
        height: size,
        colorFilter: color != null
            ? ColorFilter.mode(color!, BlendMode.srcIn)
            : null,
        placeholderBuilder: (_) => _fallback(),
        errorBuilder: (context, error, stackTrace) => _fallback(),
      );
    }

    return Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: color,
      errorBuilder: (context, error, stackTrace) => _fallback(),
    );
  }

  Widget _fallback() {
    return Icon(
      fallbackIcon,
      size: size,
      color: color ?? Colors.grey,
    );
  }
}
