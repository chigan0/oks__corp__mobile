import 'package:flutter/material.dart';

import 'app_asset_icon.dart';

/// Continuously rotating asset icon, used as a lightweight branded loader.
class SpinningAsset extends StatefulWidget {
  const SpinningAsset({
    super.key,
    required this.asset,
    this.size = 48,
    this.duration = const Duration(seconds: 1),
  });

  final String asset;
  final double size;
  final Duration duration;

  @override
  State<SpinningAsset> createState() => _SpinningAssetState();
}

class _SpinningAssetState extends State<SpinningAsset>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: AppAssetIcon(asset: widget.asset, size: widget.size),
    );
  }
}
