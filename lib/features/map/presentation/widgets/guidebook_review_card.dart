import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_svg.dart';
import '../../../home/models/guidebook_review.dart';

/// 가이드북 상세 화면 리뷰 카드(Figma `reviewCard`).
class GuidebookReviewCard extends StatelessWidget {
  const GuidebookReviewCard(this.review, {super.key});

  final GuidebookReview review;

  /// 카드 높이(리뷰 목록 높이).
  static const double height = 96;

  @override
  Widget build(BuildContext context) {
    final TextStyle meta =
        AppTextStyles.cardMetaRegular.copyWith(color: AppColors.textMuted);
    return Container(
      width: 254,
      height: height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // 넘치면 말줄임되도록 Row 대신 Text.rich 한 줄로.
                Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: AppSvg(AppIcons.star,
                            size: 8, color: AppColors.textMuted),
                      ),
                      TextSpan(
                        text:
                            ' ${_formatRating(review.rating)} · ${review.timeAgo}',
                      ),
                    ],
                  ),
                  style: meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${review.authorName} · Lv. ${review.authorLevel}',
                  style: meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            Text(
              review.content,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.placeMeta
                  .copyWith(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatRating(double rating) {
  return rating == rating.roundToDouble()
      ? rating.toStringAsFixed(1)
      : rating.toString();
}
