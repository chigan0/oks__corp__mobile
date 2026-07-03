import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';

class SegmentTabs extends StatelessWidget {
  const SegmentTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const _duration = Duration(milliseconds: 300);
  static const _curve = Curves.easeInOutCubic;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tabWidth = constraints.maxWidth / tabs.length;

        return Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: AppColors.grey200,
            borderRadius: BorderRadius.circular(AppRadius.tabOuter),
            border: Border.all(color: AppColors.grey300),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: _duration,
                curve: _curve,
                left: selectedIndex * tabWidth,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.tabInner),
                  ),
                ),
              ),
              Row(
                children: List.generate(tabs.length, (index) {
                  final selected = index == selectedIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onChanged(index),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: 5,
                        ),
                        child: AnimatedDefaultTextStyle(
                          duration: _duration,
                          curve: _curve,
                          style: selected
                              ? AppTypography.tabLabelActive
                              : AppTypography.tabLabel,
                          child: Text(
                            tabs[index],
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
