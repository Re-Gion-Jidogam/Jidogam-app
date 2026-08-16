import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_svg.dart';
import '../../models/place.dart';

/// "장소" 탭 추천 리스트 카드 — 이름·카테고리·평점·주소만 노출(사진 없음).
class PlaceListCard extends StatelessWidget {
  const PlaceListCard(this.place, {super.key, this.onTap});

  final Place place;
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
        child: Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(place.name, style: AppTextStyles.placeTitle14),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(place.category, style: AppTextStyles.placeMeta),
                  const SizedBox(width: 4),
                  Text('·', style: AppTextStyles.placeMeta),
                  const SizedBox(width: 4),
                  AppSvg(AppIcons.star, size: 8, color: AppColors.textSecondary),
                  const SizedBox(width: 2),
                  Text(_rating(place.rating), style: AppTextStyles.placeMeta),
                ],
              ),
              const SizedBox(height: 4),
              Text(place.address, style: AppTextStyles.placeMeta),
            ],
          ),
        ),
      ),
    );
  }

  String _rating(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(1) : v.toString();
}
