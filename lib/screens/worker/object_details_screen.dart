import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../entities/construction_object/model/construction_object.dart';
import '../../entities/construction_object/model/object_status.dart';
import '../../entities/user_profile/model/user_profile.dart';
import '../../features/construction_objects/objects_notifier.dart';
import '../../entities/user_profile/repository/mock_user_repository.dart';
import '../../features/language_switcher/language_notifier.dart';
import '../../features/language_switcher/widgets/language_sheet.dart';
import '../../features/profile/api/profile_api.dart';
import '../../features/profile/widgets/profile_sheet.dart';
import '../../features/qr_display/widgets/object_select_sheet.dart';
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

  void _showObjectSelect(BuildContext context, bool isKz) {
    final objects = context.read<ObjectsNotifier>().getAccessibleObjects();
    showAppModalBottomSheet<void>(
      context,
      Builder(
        builder: (sheetContext) => ObjectSelectSheet(
          objects: objects,
          isKz: isKz,
          onClose: () => Navigator.of(sheetContext).pop(),
          onSelect: (object) {
            Navigator.of(sheetContext).pop();
            _showQrPass(context, object, isKz);
          },
        ),
      ),
      initialChildSize: 0.5,
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
          onBack: () {
            Navigator.of(sheetContext).pop();
            _showObjectSelect(context, isKz);
          },
          onClose: () => Navigator.of(sheetContext).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final objectsNotifier = context.watch<ObjectsNotifier>();
    final object = objectsNotifier.findById(objectId);
    final isKz = context.watch<LanguageNotifier>().isKz;
    final dateFormat = DateFormat('dd.MM.yyyy');

    if (object == null && objectsNotifier.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator()),
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
                      DetailInfoPanel(
                        children: [
                          DetailRow(
                            label: isKz ? 'Мекенжай' : 'Адрес',
                            value: object.address,
                          ),
                          DetailRow(
                            label: isKz ? 'Нысан статусы' : 'Статус объекта',
                            value: object.objectStatus.labelRu(isKz),
                          ),
                          DetailRow(
                            label: isKz ? 'Рұқсат статусы' : 'Статус допуска',
                            valueWidget: StatusBadge(
                              status: object.accessStatus,
                              isKz: isKz,
                            ),
                          ),
                          DetailRow(
                            label: isKz ? 'Берілген күні' : 'Дата выдачи',
                            value: dateFormat.format(object.issueDate),
                          ),
                          if (object.accessExpiryDate != null)
                            DetailRow(
                              label: isKz ? 'Рұқсат мерзімі' : 'Срок допуска',
                              value: dateFormat.format(object.accessExpiryDate!),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(docsLabel, style: AppTypography.profileSectionTitle),
                      const SizedBox(height: AppSpacing.lg),
                      Column(
                        children: [
                          for (var i = 0; i < object.documents.length; i++) ...[
                            if (i > 0) const SizedBox(height: AppSpacing.sm),
                            DocumentTile(
                              fileName: object.documents[i].fileName,
                              uploadedAt: object.documents[i].uploadedAt,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              FloatingBottomBar(
                qrLabel: qrLabel,
                onProfile: () => _showProfile(context, isKz),
                onShowQr: () => _showObjectSelect(context, isKz),
                onLanguage: () => _showLanguage(context, isKz),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
