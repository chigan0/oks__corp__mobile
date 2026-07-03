import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../app/theme/app_scanner.dart';
import '../../../app/theme/app_typography.dart';

/// Radial scrim + yellow corner brackets + hint text (Figma «Сканирование»).
class ScanOverlay extends StatelessWidget {
  const ScanOverlay({
    super.key,
    required this.hintText,
    this.viewfinderSize = AppScanner.viewfinderSize,
    this.cornerRadius = AppScanner.viewfinderCornerRadius,
  });

  final String hintText;
  final double viewfinderSize;
  final double cornerRadius;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = Size(constraints.maxWidth, constraints.maxHeight);
        final viewfinderRect = _viewfinderRect(screenSize);

        return Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            CustomPaint(
              painter: _RadialScrimPainter(
                viewfinderRect: viewfinderRect,
                screenSize: screenSize,
              ),
              size: Size.infinite,
            ),
            CustomPaint(
              painter: _ScannerCornerPainter(
                cutoutRect: viewfinderRect,
                cornerRadius: cornerRadius,
              ),
              size: Size.infinite,
            ),
            Positioned(
              left: AppScanner.headerHorizontalPadding,
              right: AppScanner.headerHorizontalPadding,
              top: viewfinderRect.top -
                  AppScanner.hintToViewfinderGap -
                  AppScanner.hintLineHeight,
              child: Text(
                hintText,
                textAlign: TextAlign.center,
                style: AppTypography.scannerHint,
              ),
            ),
          ],
        );
      },
    );
  }

  Rect _viewfinderRect(Size screenSize) {
    return Rect.fromCenter(
      center: Offset(screenSize.width / 2, screenSize.height / 2),
      width: viewfinderSize,
      height: viewfinderSize,
    );
  }
}

class _RadialScrimPainter extends CustomPainter {
  _RadialScrimPainter({
    required this.viewfinderRect,
    required this.screenSize,
  });

  final Rect viewfinderRect;
  final Size screenSize;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height * AppScanner.overlayGradientCenterYFactor,
    );
    final radius = size.shortestSide * AppScanner.overlayGradientRadiusFactor;

    final paint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        radius,
        AppScanner.overlayGradientColors,
        AppScanner.overlayGradientStops,
      );

    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _RadialScrimPainter oldDelegate) {
    return oldDelegate.viewfinderRect != viewfinderRect ||
        oldDelegate.screenSize != screenSize;
  }
}

class _ScannerCornerPainter extends CustomPainter {
  _ScannerCornerPainter({
    required this.cutoutRect,
    required this.cornerRadius,
  });

  final Rect cutoutRect;
  final double cornerRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppScanner.cornerColor
      ..strokeWidth = AppScanner.cornerStroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final r = math.min(cornerRadius, cutoutRect.shortestSide / 2);
    final left = cutoutRect.left;
    final top = cutoutRect.top;
    final right = cutoutRect.right;
    final bottom = cutoutRect.bottom;

    _drawTopLeft(canvas, paint, left, top, r);
    _drawTopRight(canvas, paint, right, top, r);
    _drawBottomLeft(canvas, paint, left, bottom, r);
    _drawBottomRight(canvas, paint, right, bottom, r);
  }

  void _drawTopLeft(Canvas canvas, Paint paint, double left, double top, double r) {
    final arm = AppScanner.cornerArm;
    final path = Path()
      ..moveTo(left, top + arm)
      ..lineTo(left, top + r)
      ..addArc(Rect.fromLTWH(left, top, r * 2, r * 2), math.pi, math.pi / 2)
      ..lineTo(left + arm, top);
    canvas.drawPath(path, paint);
  }

  void _drawTopRight(Canvas canvas, Paint paint, double right, double top, double r) {
    final arm = AppScanner.cornerArm;
    final path = Path()
      ..moveTo(right - arm, top)
      ..lineTo(right - r, top)
      ..addArc(
        Rect.fromLTWH(right - r * 2, top, r * 2, r * 2),
        math.pi * 1.5,
        math.pi / 2,
      )
      ..lineTo(right, top + arm);
    canvas.drawPath(path, paint);
  }

  void _drawBottomLeft(Canvas canvas, Paint paint, double left, double bottom, double r) {
    final arm = AppScanner.cornerArm;
    final path = Path()
      ..moveTo(left, bottom - arm)
      ..lineTo(left, bottom - r)
      ..addArc(
        Rect.fromLTWH(left, bottom - r * 2, r * 2, r * 2),
        math.pi,
        -math.pi / 2,
      )
      ..lineTo(left + arm, bottom);
    canvas.drawPath(path, paint);
  }

  void _drawBottomRight(Canvas canvas, Paint paint, double right, double bottom, double r) {
    final arm = AppScanner.cornerArm;
    final path = Path()
      ..moveTo(right, bottom - arm)
      ..lineTo(right, bottom - r)
      ..addArc(
        Rect.fromLTWH(right - r * 2, bottom - r * 2, r * 2, r * 2),
        0,
        math.pi / 2,
      )
      ..lineTo(right - arm, bottom);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ScannerCornerPainter oldDelegate) {
    return oldDelegate.cutoutRect != cutoutRect ||
        oldDelegate.cornerRadius != cornerRadius;
  }
}
