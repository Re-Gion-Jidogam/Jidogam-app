import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_svg.dart';
import '../../../../core/widgets/chevron_right.dart';
import '../../models/place.dart';

/// 가이드북 상세 화면의 열람용 장소 카드(Figma `placeCard`).
///
/// 방문한 장소는 회색 배경 + TRAVEL 도장 워터마크 + 방문일을 보여준다.
class GuidebookPlaceCard extends StatelessWidget {
  const GuidebookPlaceCard(this.place, {super.key, this.onGuidebookTap});

  final Place place;
  final VoidCallback? onGuidebookTap;

  @override
  Widget build(BuildContext context) {
    final DateTime? visitedDate = place.visitedDate;
    final bool isVisited = visitedDate != null;
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isVisited ? AppColors.background : AppColors.surface,
        border: Border.all(color: AppColors.gray200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: <Widget>[
          // 우상단 도장 워터마크([StampCard]와 동일).
          if (isVisited)
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
            padding: const EdgeInsets.all(12),
            child: _buildBody(visitedDate),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(DateTime? visitedDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
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
                  Text(place.categoryName, style: AppTextStyles.placeMeta),
                  const SizedBox(width: 4),
                  Text('·', style: AppTextStyles.placeMeta),
                  const SizedBox(width: 4),
                  if (place.rating != null) ...<Widget>[
                    AppSvg(
                      AppIcons.star,
                      size: 8,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 2),
                  ],
                  Text(_rating(place.rating), style: AppTextStyles.placeMeta),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                visitedDate == null
                    ? place.roadAddress
                    : '${place.roadAddress} · ${_formatVisitedDate(visitedDate)}에 도장찍음',
                style: AppTextStyles.placeMeta,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onGuidebookTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '이 장소가 포함된 가이드북 ${_formatCount(place.guidebookCount)}개',
                style: AppTextStyles.placeMeta,
              ),
              const SizedBox(width: 6),
              const ChevronRight(length: 8),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _PhotoRow(place.photos),
      ],
    );
  }

  String _formatVisitedDate(DateTime d) => '${d.year}. ${d.month}. ${d.day}';

  /// 평점이 없으면(리뷰 API 연동 전) '별점없음'.
  String _rating(double? v) {
    if (v == null) return '별점없음';
    return v == v.roundToDouble() ? v.toStringAsFixed(1) : v.toString();
  }

  String _formatCount(int n) {
    final String s = n.toString();
    final StringBuffer buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _PhotoRow extends StatelessWidget {
  const _PhotoRow(this.photos);

  final List<String> photos;

  @override
  Widget build(BuildContext context) {
    final List<String> shown = photos.take(3).toList();
    if (shown.isEmpty) return const SizedBox.shrink();
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
