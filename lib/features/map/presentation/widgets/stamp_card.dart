import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_svg.dart';
import '../../models/stamp.dart';

/// 내 도장 리스트 카드 — 장소 정보 + TRAVEL 도장 워터마크(카드 우상단 코너에 살짝 걸침).
class StampCard extends StatelessWidget {
  const StampCard(this.stamp, {super.key, this.onTap});

  final Stamp stamp;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.cardShadow,
        ),
        child: Stack(
          children: <Widget>[
            // 카드 우상단 모서리 밖으로 살짝 걸치는 TRAVEL 도장 워터마크.
            Positioned(
              right: -32,
              top: -18,
              child: Opacity(
                opacity: 0.15,
                child: Transform.rotate(
                  angle: -20 * math.pi / 180,
                  child: Image.asset(AppImages.travelStamp, width: 150),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(stamp.placeName, style: AppTextStyles.placeTitle14),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(stamp.category, style: AppTextStyles.placeMeta),
                      const SizedBox(width: 4),
                      Text('·', style: AppTextStyles.placeMeta),
                      const SizedBox(width: 4),
                      AppSvg(
                        AppIcons.star,
                        size: 8,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        _rating(stamp.rating),
                        style: AppTextStyles.placeMeta,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${stamp.address} · ${stamp.stampedDate}에 도장찍음',
                    style: AppTextStyles.placeMeta,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _rating(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(1) : v.toString();
}
