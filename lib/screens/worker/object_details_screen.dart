import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_fonts.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../entities/construction_object/model/construction_object.dart';
import '../../entities/construction_object/model/facility_document.dart';
import '../../entities/construction_object/model/object_status.dart';
import '../../entities/user_profile/model/user_profile.dart';
import '../../entities/user_profile/repository/mock_user_repository.dart';
import '../../features/construction_objects/api/facilities_api.dart';
import '../../features/construction_objects/facility_details_notifier.dart';
import '../../features/construction_objects/objects_notifier.dart';
import '../../features/language_switcher/language_notifier.dart';
import '../../features/language_switcher/widgets/language_sheet.dart';
import '../../features/profile/api/profile_api.dart';
import '../../features/profile/widgets/profile_sheet.dart';
import '../../features/qr_display/widgets/qr_pass_sheet.dart';
import '../../shared/ui/bottom_sheet_launchers.dart';
import '../../shared/ui/detail_row.dart';
import '../../shared/ui/document_tile.dart';
import '../../shared/ui/floating_bottom_bar.dart';
import '../../shared/ui/bottom_sheets/sheet_icon_button.dart';
import '../../shared/ui/status_badge.dart';

class ObjectDetailsScreen extends StatelessWidget {
  const ObjectDetailsScreen({super.key, required this.objectId});

  final String objectId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FacilityDetailsNotifier>(
      create: (ctx) => FacilityDetailsNotifier(
        api: ctx.read<FacilitiesApi>(),
        facilityUuid: objectId,
      ),
      child: _ObjectDetailsBody(objectId: objectId),
    );
  }
}

class _ObjectDetailsBody extends StatelessWidget {
  const _ObjectDetailsBody({required this.objectId});

  final String objectId;

  Future<void> _showProfile(BuildContext context, bool isKz) async {
    final mockProfile = MockUserRepository.instance.workerProfile;
    var phone = mockProfile.phone;
    try {
      final account = await context.read<ProfileApi>().fetchProfile();
      phone = account.phone;
    } catch (_) {
      // Fall back to the mock phone if the profile request fails.
    }
    if (!context.mounted) return;

    final profile = UserProfile(
      id: mockProfile.id,
      fullName: mockProfile.fullName,
      company: mockProfile.company,
      iin: mockProfile.iin,
      phone: phone,
      documents: mockProfile.documents,
    );
    showAppModalBottomSheet<void>(
      context,
      ProfileSheet(
        profile: profile,
        isKz: isKz,
        onClose: () => Navigator.of(context).pop(),
      ),
      initialChildSize: 0.6,
    );
  }

  void _showLanguage(BuildContext context, bool isKz) {
    final notifier = context.read<LanguageNotifier>();
    showLanguageModalBottomSheet<void>(
      context,
      LanguageSheet(
        isKz: isKz,
        selected: notifier.language,
        onSelect: (lang) {
          notifier.setLanguage(lang);
          Navigator.of(context).pop();
        },
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _showQrPass(BuildContext context, ConstructionObject object, bool isKz) {
    showQrPassModalBottomSheet<void>(
      context,
      Builder(
        builder: (sheetContext) => QrPassSheet(
          object: object,
          isKz: isKz,
          onBack: () => Navigator.of(sheetContext).pop(),
          onClose: () => Navigator.of(sheetContext).pop(),
        ),
      ),
    );
  }

  Future<void> _openDocument(BuildContext context, FacilityDocument document) async {
    final uri = Uri.tryParse(document.url);
    final opened = uri != null && await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось открыть «${document.name}»')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final objectsNotifier = context.watch<ObjectsNotifier>();
    final object = objectsNotifier.findById(objectId);
    final isKz = context.watch<LanguageNotifier>().isKz;
    final detailsNotifier = context.watch<FacilityDetailsNotifier>();

    if (object == null && objectsNotifier.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (object == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Объект не найден')),
      );
    }

    final qrLabel = isKz ? 'QR көрсету' : 'Показать QR';
    final docsLabel = isKz ? 'Құжаттар' : 'Документы';

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppSpacing.screenHeaderTopInset),
                      SizedBox(
                        height: 42,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              object.name,
                              textAlign: TextAlign.center,
                              style: AppTypography.screenTitlePrimary,
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: SheetIconButton(
                                icon: Icons.chevron_left,
                                onPressed: () => context.pop(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _DetailsSection(notifier: detailsNotifier, isKz: isKz),
                      const SizedBox(height: AppSpacing.xl),
                      Text(docsLabel, style: AppTypography.profileSectionTitle),
                      const SizedBox(height: AppSpacing.lg),
                      _DocumentsSection(
                        notifier: detailsNotifier,
                        isKz: isKz,
                        onOpen: (doc) => _openDocument(context, doc),
                      ),
                    ],
                  ),
                ),
              ),
              FloatingBottomBar(
                qrLabel: qrLabel,
                onProfile: () => _showProfile(context, isKz),
                onShowQr: () => _showQrPass(context, object, isKz),
                onLanguage: () => _showLanguage(context, isKz),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailsSection extends StatelessWidget {
  const _DetailsSection({required this.notifier, required this.isKz});

  final FacilityDetailsNotifier notifier;
  final bool isKz;

  @override
  Widget build(BuildContext context) {
    if (notifier.detailsStatus == FacilityLoadStatus.loading) {
      return const DetailInfoPanel(isLoading: true, children: []);
    }

    if (notifier.detailsStatus == FacilityLoadStatus.error) {
      return _InlineError(
        message: notifier.detailsError?.message ??
            (isKz ? 'Деректерді жүктеу мүмкін болмады' : 'Не удалось загрузить данные'),
        onRetry: notifier.loadDetails,
      );
    }

    final details = notifier.details!;
    final dateFormat = DateFormat('dd.MM.yyyy');

    return DetailInfoPanel(
      children: [
        DetailRow(
          label: isKz ? 'Мекенжай' : 'Адрес',
          value: details.address,
        ),
        DetailRow(
          label: isKz ? 'Нысан статусы' : 'Статус объекта',
          value: details.status.labelRu(isKz),
        ),
        DetailRow(
          label: isKz ? 'Рұқсат статусы' : 'Статус допуска',
          valueWidget: StatusBadge(status: details.accessStatus, isKz: isKz),
        ),
        if (details.issuedAt != null)
          DetailRow(
            label: isKz ? 'Берілген күні' : 'Дата выдачи',
            value: dateFormat.format(details.issuedAt!),
          ),
        if (details.plannedStartYear != null)
          DetailRow(
            label: isKz ? 'Құрылыс басталуы' : 'Начало строительства',
            value: _quarterYear(details.plannedStartQuarter, details.plannedStartYear!, isKz),
          ),
        if (details.plannedYear > 0)
          DetailRow(
            label: isKz ? 'Тапсыру мерзімі' : 'Плановый срок сдачи',
            value: _quarterYear(details.plannedQuarter, details.plannedYear, isKz),
          ),
      ],
    );
  }

  String _quarterYear(String? quarter, int year, bool isKz) {
    if (quarter == null || quarter.isEmpty) return '$year';
    return isKz ? '$year ж. $quarter тоқсан' : '$quarter кв. $year';
  }
}

class _DocumentsSection extends StatelessWidget {
  const _DocumentsSection({
    required this.notifier,
    required this.isKz,
    required this.onOpen,
  });

  final FacilityDetailsNotifier notifier;
  final bool isKz;
  final ValueChanged<FacilityDocument> onOpen;

  @override
  Widget build(BuildContext context) {
    if (notifier.documentsStatus == FacilityLoadStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (notifier.documentsStatus == FacilityLoadStatus.error) {
      return _InlineError(
        message: notifier.documentsError?.message ??
            (isKz ? 'Құжаттарды жүктеу мүмкін болмады' : 'Не удалось загрузить документы'),
        onRetry: notifier.loadDocuments,
      );
    }

    final documents = notifier.documents;
    if (documents.isEmpty) {
      return Text(
        isKz ? 'Құжаттар жоқ' : 'Документов пока нет',
        style: AppTypography.screenHint,
      );
    }

    return Column(
      children: [
        for (var i = 0; i < documents.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.sm),
          DocumentTile(
            fileName: documents[i].name,
            onDownload: () => onOpen(documents[i]),
          ),
        ],
      ],
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message,
          style: const TextStyle(
            fontFamily: AppFonts.manrope,
            fontSize: 14,
            color: AppColors.redText,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextButton(
          onPressed: onRetry,
          child: const Text('Повторить'),
        ),
      ],
    );
  }
}
