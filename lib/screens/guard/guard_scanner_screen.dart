import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../app/theme/app_colors.dart';
import '../../entities/construction_object/repository/object_repository.dart';
import '../../entities/worker/model/scanned_worker.dart';
import '../../features/access_confirmation/widgets/confirm_access_sheet.dart';
import '../../features/access_confirmation/widgets/denial_dialog.dart';
import '../../features/access_confirmation/widgets/success_dialog.dart';
import '../../features/qr_scanning/api/mock_scan_api.dart';
import '../../features/qr_scanning/widgets/scan_overlay.dart';
import '../../features/qr_scanning/widgets/scanner_header.dart';
import '../../shared/ui/bottom_sheets/sheet_icon_button.dart';

class GuardScannerScreen extends StatefulWidget {
  const GuardScannerScreen({super.key});

  @override
  State<GuardScannerScreen> createState() => _GuardScannerScreenState();
}

class _GuardScannerScreenState extends State<GuardScannerScreen> {
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _isProcessing = false;
  bool _hasScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing || _hasScanned) return;

    final barcode = capture.barcodes.firstOrNull;
    final rawValue = barcode?.rawValue;
    if (rawValue == null) return;

    setState(() {
      _isProcessing = true;
      _hasScanned = true;
    });

    await _controller.stop();

    final result = await MockScanApi.instance.verifyQrCode(rawValue);
    if (!mounted) return;

    await _showConfirmSheet(result.worker);

    if (mounted) {
      setState(() {
        _isProcessing = false;
        _hasScanned = false;
      });
      await _controller.start();
    }
  }

  Future<void> _showConfirmSheet(ScannedWorker worker) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: ConfirmAccessSheet(
          worker: worker,
          onDeny: () {
            Navigator.of(sheetContext).pop();
            _showDenialDialog(worker.fullName);
          },
          onGrant: () {
            Navigator.of(sheetContext).pop();
            _showSuccessDialog(worker.fullName);
          },
        ),
      ),
    );
  }

  Future<void> _showSuccessDialog(String name) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => SuccessDialog(
        workerName: name,
        onAccepted: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  Future<void> _showDenialDialog(String name) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => DenialDialog(
        workerName: name,
        onAccepted: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final guardObject = ObjectRepository.instance.localObjects.first;
    final title = 'Объект \u201c${guardObject.name}\u201d';

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
            ),
            const ScanOverlay(hintText: 'Сканируйте QR-пропуск'),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ScannerHeader(
                title: title,
                closeButton: SheetIconButton(
                  icon: Icons.close,
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            if (_isProcessing)
              const Center(
                child: CircularProgressIndicator(color: AppColors.yellow),
              ),
          ],
        ),
      ),
    );
  }
}
