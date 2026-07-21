import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_svg.dart';
import '../models/place.dart';

/// 장소 카드 (폭 328).
///
/// 장소 정보(이름·카테고리·평점·주소) + 사진 3장 썸네일.
class PlaceCard extends StatelessWidget {
  const PlaceCard(this.place, {super.key, this.onTap});

  final Place place;
  final VoidCallback? onTap;

  static const double _width = 328;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: _width,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _PlaceInfo(place),
            const SizedBox(height: 14),
            _PhotoRow(place.photos),
          ],
        ),
      ),
    );
  }
}

class _PlaceInfo extends StatelessWidget {
  const _PlaceInfo(this.place);

  final Place place;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              Text(_formatRating(place.rating), style: AppTextStyles.placeMeta),
            ],
          ),
          const SizedBox(height: 4),
          Text(place.address, style: AppTextStyles.placeMeta),
        ],
      ),
    );
  }
}

class _PhotoRow extends StatelessWidget {
  const _PhotoRow(this.photos);

  final List<String> photos;

  @override
  Widget build(BuildContext context) {
    final List<String> shown = photos.take(3).toList();
    return SizedBox(
      height: 93.33,
      child: Row(
        children: <Widget>[
          for (int i = 0; i < shown.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  shown[i],
                  fit: BoxFit.cover,
                  height: double.infinity,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _formatRating(double rating) {
  return rating == rating.roundToDouble()
      ? rating.toStringAsFixed(1)
      : rating.toString();
}
