import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_fonts.dart';
import '../../app/theme/app_spacing.dart';
import '../../entities/worker/model/scanned_worker.dart';
import '../../features/access_confirmation/widgets/access_denied_screen.dart';
import '../../features/access_confirmation/widgets/confirm_access_sheet.dart';
import '../../features/access_confirmation/widgets/denial_dialog.dart';
import '../../features/access_confirmation/widgets/success_dialog.dart';
import '../../features/qr_scanning/api/qr_validation_api.dart';
import '../../features/qr_scanning/widgets/scan_overlay.dart';
import '../../features/qr_scanning/widgets/scanner_header.dart';
import '../../shared/ui/bottom_sheets/sheet_icon_button.dart';

class GuardScannerScreen extends StatefulWidget {
  const GuardScannerScreen({super.key});

  @override
  State<GuardScannerScreen> createState() => _GuardScannerScreenState();
}

class _GuardScannerScreenState extends State<GuardScannerScreen> {
  /// Ignores repeat detections of the same code while it's still in the camera frame.
  static const _rescanCooldown = Duration(seconds: 2);

  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    formats: const [BarcodeFormat.qrCode],
  );

  PermissionStatus? _cameraPermission;
  bool _isProcessing = false;
  DateTime? _lastScanAt;
  String? _lastScannedCode;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (!mounted) return;
    setState(() => _cameraPermission = status);
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    setState(() => _cameraPermission = status);
  }

  bool _isDebounced(String code) {
    final now = DateTime.now();
    return _lastScannedCode == code &&
        _lastScanAt != null &&
        now.difference(_lastScanAt!) < _rescanCooldown;
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.format != BarcodeFormat.qrCode) return;

    final rawValue = barcode.rawValue?.trim();
    if (rawValue == null || rawValue.isEmpty || _isDebounced(rawValue)) return;

    _lastScannedCode = rawValue;
    _lastScanAt = DateTime.now();

    setState(() => _isProcessing = true);
    await _controller.stop();
    if (!mounted) return;

    try {
      final worker = await context.read<QrValidationApi>().validate(rawValue);
      if (mounted) await _showConfirmSheet(worker);
    } on QrValidationException catch (error) {
      if (!mounted) return;
      if (error.type == QrValidationErrorType.notFound) {
        await _showAccessDenied(error.message);
      } else {
        _showSnackBar(error.message);
      }
    } catch (_) {
      _showSnackBar('Не удалось проверить код. Попробуйте позже');
    }

    if (!mounted) return;
    setState(() => _isProcessing = false);
    await _controller.start();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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

  Future<void> _showAccessDenied(String message) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (routeContext) => AccessDeniedScreen(
          message: message,
          onDismiss: () => Navigator.of(routeContext).pop(),
        ),
      ),
    );
  }

  static const _title = 'Проверка пропуска';

  @override
  Widget build(BuildContext context) {
    final hasCameraAccess = _cameraPermission?.isGranted ?? false;

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (hasCameraAccess) ...[
              MobileScanner(
                controller: _controller,
                onDetect: _onDetect,
              ),
              const ScanOverlay(hintText: 'Сканируйте QR-пропуск'),
            ] else if (_cameraPermission != null)
              _CameraPermissionRequest(
                isPermanentlyDenied: _cameraPermission!.isPermanentlyDenied,
                onRequest: _requestCameraPermission,
              ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ScannerHeader(
                title: _title,
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

class _CameraPermissionRequest extends StatelessWidget {
  const _CameraPermissionRequest({
    required this.isPermanentlyDenied,
    required this.onRequest,
  });

  final bool isPermanentlyDenied;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.no_photography_outlined, color: Colors.white, size: 56),
            const SizedBox(height: AppSpacing.lg),
            Text(
              isPermanentlyDenied
                  ? 'Доступ к камере заблокирован. Включите его в настройках устройства, чтобы сканировать пропуска.'
                  : 'Для сканирования QR-пропусков нужен доступ к камере.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppFonts.manrope,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton(
              onPressed: isPermanentlyDenied ? () => openAppSettings() : onRequest,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
              ),
              child: Text(isPermanentlyDenied ? 'Открыть настройки' : 'Разрешить доступ'),
            ),
          ],
        ),
      ),
    );
  }
}
