import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_svg.dart';
import '../../models/stamp.dart';

/// 내 도장 리스트 카드 — 장소 정보 + TRAVEL 도장 워터마크.
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.cardShadow,
        ),
        child: Stack(
          children: <Widget>[
            const Positioned(right: 0, top: 4, child: _TravelStamp()),
            Column(
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
                    AppSvg(AppIcons.star,
                        size: 8, color: AppColors.textSecondary),
                    const SizedBox(width: 2),
                    Text(_rating(stamp.rating), style: AppTextStyles.placeMeta),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${stamp.address} · ${stamp.stampedDate}에 도장찍음',
                  style: AppTextStyles.placeMeta,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _rating(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(1) : v.toString();
}

/// TRAVEL 도장 워터마크(근사).
class _TravelStamp extends StatelessWidget {
  const _TravelStamp();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.14,
      child: Transform.rotate(
        angle: -0.14,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.gray700, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.wb_sunny_outlined,
                  size: 14, color: AppColors.gray700),
              const SizedBox(height: 2),
              Text(
                'TRAVEL',
                style: AppTextStyles.helper.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
