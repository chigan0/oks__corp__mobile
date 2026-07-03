import 'package:flutter/material.dart';

/// Draggable, scrollable host for modal bottom sheets.
/// SafeArea must live inside each sheet's white container, not here.
class DraggableBottomSheetHost extends StatelessWidget {
  const DraggableBottomSheetHost({
    super.key,
    required this.child,
    this.initialChildSize = 0.45,
    this.minChildSize = 0.2,
    this.maxChildSize = 0.92,
    this.fillViewport = true,
  });

  final Widget child;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;

  /// When true, the scroll child expands to at least the sheet viewport height.
  final bool fillViewport;

  @override
  Widget build(BuildContext context) {
    final isFullHeight = initialChildSize >= maxChildSize - 0.001;

    return DraggableScrollableSheet(
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      expand: isFullHeight,
      builder: (context, scrollController) {
        if (!fillViewport) {
          return SingleChildScrollView(
            controller: scrollController,
            physics: const ClampingScrollPhysics(),
            child: child,
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              controller: scrollController,
              physics: const ClampingScrollPhysics(),
              child: SizedBox(
                height: constraints.maxHeight,
                width: constraints.maxWidth,
                child: child,
              ),
            );
          },
        );
      },
    );
  }
}

Future<T?> showAppModalBottomSheet<T>(
  BuildContext context,
  Widget sheet, {
  double initialChildSize = 0.45,
  double? minChildSize,
  double? maxChildSize,
  bool fillViewport = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => DraggableBottomSheetHost(
      initialChildSize: initialChildSize,
      minChildSize: minChildSize ?? 0.2,
      maxChildSize: maxChildSize ?? 0.92,
      fillViewport: fillViewport,
      child: sheet,
    ),
  );
}

/// Fixed-size modal: opens at [size] and cannot be dragged to another height.
Future<T?> showFixedModalBottomSheet<T>(
  BuildContext context,
  Widget sheet, {
  required double size,
  bool fillViewport = true,
}) {
  return showAppModalBottomSheet<T>(
    context,
    sheet,
    initialChildSize: size,
    minChildSize: size,
    maxChildSize: size,
    fillViewport: fillViewport,
  );
}

/// QR pass sheet at 60% screen height.
Future<T?> showQrPassModalBottomSheet<T>(
  BuildContext context,
  Widget sheet,
) {
  return showFixedModalBottomSheet<T>(
    context,
    sheet,
    size: 0.75,
    fillViewport: true,
  );
}

/// Language picker at 40% screen height.
Future<T?> showLanguageModalBottomSheet<T>(
  BuildContext context,
  Widget sheet,
) {
  return showFixedModalBottomSheet<T>(
    context,
    sheet,
    size: 0.4,
  );
}
