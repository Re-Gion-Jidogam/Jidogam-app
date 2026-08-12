import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../providers/map_providers.dart';

/// 상단 세그먼트 pill — 내 도장 / 장소 / 가이드북.
class MapSegmentedControl extends ConsumerWidget {
  const MapSegmentedControl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MapSegment selected = ref.watch(mapSegmentProvider);

    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
        child: Container(
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0x1A000000),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: const Color(0x33FFFFFF)),
          ),
          child: Row(
            children: <Widget>[
              for (final MapSegment segment in MapSegment.values)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () =>
                        ref.read(mapSegmentProvider.notifier).state = segment,
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      alignment: Alignment.center,
                      decoration: segment == selected
                          ? BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(100),
                              boxShadow: AppColors.cardShadow,
                            )
                          : null,
                      child: Text(
                        segment.label,
                        style: AppTextStyles.navLabel.copyWith(
                          fontSize: 12,
                          color: AppColors.sheetTitle,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
