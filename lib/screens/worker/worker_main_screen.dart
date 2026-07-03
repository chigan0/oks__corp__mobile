import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../entities/construction_object/model/construction_object.dart';
import '../../features/construction_objects/objects_notifier.dart';
import '../../entities/user_profile/repository/mock_user_repository.dart';
import '../../features/language_switcher/language_notifier.dart';
import '../../features/language_switcher/widgets/language_sheet.dart';
import '../../features/profile/widgets/profile_sheet.dart';
import '../../features/qr_display/widgets/object_select_sheet.dart';
import '../../features/qr_display/widgets/qr_pass_sheet.dart';
import '../../shared/ui/bottom_sheet_launchers.dart';
import '../../shared/ui/floating_bottom_bar.dart';
import '../../shared/ui/object_card.dart';
import '../../shared/ui/oks_header.dart';
import '../../shared/ui/segment_tabs.dart';

class WorkerMainScreen extends StatefulWidget {
  const WorkerMainScreen({super.key});

  @override
  State<WorkerMainScreen> createState() => _WorkerMainScreenState();
}

class _WorkerMainScreenState extends State<WorkerMainScreen> {
  int _tabIndex = 0;

  bool get _isKz => context.read<LanguageNotifier>().isKz;

  void _showProfile() {
    final profile = MockUserRepository.instance.workerProfile;
    showAppModalBottomSheet<void>(
      context,
      ProfileSheet(
        profile: profile,
        isKz: _isKz,
        onClose: () => Navigator.of(context).pop(),
      ),
      initialChildSize: 0.6,
    );
  }

  void _showObjectSelect() {
    final objects = context.read<ObjectsNotifier>().getAccessibleObjects();
    showAppModalBottomSheet<void>(
      context,
      ObjectSelectSheet(
        objects: objects,
        isKz: _isKz,
        onClose: () => Navigator.of(context).pop(),
        onSelect: (object) {
          Navigator.of(context).pop();
          _showQrPass(object);
        },
      ),
      initialChildSize: 0.5,
    );
  }

  void _showLanguage() {
    final notifier = context.read<LanguageNotifier>();
    showLanguageModalBottomSheet<void>(
      context,
      LanguageSheet(
        isKz: _isKz,
        selected: notifier.language,
        onSelect: (lang) {
          notifier.setLanguage(lang);
          Navigator.of(context).pop();
        },
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _showQrPass(ConstructionObject object) {
    showQrPassModalBottomSheet<void>(
      context,
      QrPassSheet(
        object: object,
        isKz: _isKz,
        onBack: () {
          Navigator.of(context).pop();
          _showObjectSelect();
        },
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isKz = context.watch<LanguageNotifier>().isKz;
    final objectsNotifier = context.watch<ObjectsNotifier>();
    final objects = objectsNotifier.objects;

    final title = isKz ? 'Менің пропускім' : 'Мой пропуск';
    final tabObjects = isKz ? 'Нысандар' : 'Объекты';
    final tabHistory = isKz ? 'Келу тарихы' : 'История посещений';
    final hint = isKz
        ? 'Мұнда сізге рұқсат берілген барлық нысандар көрсетілген'
        : 'Здесь показаны все объекты, к которым у вас есть допуск';
    final qrLabel = isKz ? 'QR көрсету' : 'Показать QR';
    final historyPlaceholder = isKz
        ? 'Бұл блок әлі әзірленуде'
        : 'Этот блок ещё находится в разработке';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/roles');
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OksHeader(
                      title: title,
                      onLogoTap: () => context.go('/roles'),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    SegmentTabs(
                      tabs: [tabObjects, tabHistory],
                      selectedIndex: _tabIndex,
                      onChanged: (i) => setState(() => _tabIndex = i),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(hint, style: AppTypography.screenHint),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  children: [
                    if (_tabIndex == 0)
                      ...objects.map(
                        (obj) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                          child: ObjectCard(
                            object: obj,
                            isKz: isKz,
                            iconColor: const Color(0xFF9296E3),
                            onTap: () =>
                                context.push('/worker/object/${obj.id}'),
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xxxl),
                        child: Text(
                          historyPlaceholder,
                          textAlign: TextAlign.center,
                          style: AppTypography.screenHint,
                        ),
                      ),
                  ],
                ),
              ),
              FloatingBottomBar(
                qrLabel: qrLabel,
                onProfile: _showProfile,
                onShowQr: _showObjectSelect,
                onLanguage: _showLanguage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
