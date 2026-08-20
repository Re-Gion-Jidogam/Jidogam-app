import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_svg.dart';
import '../../../../core/widgets/chevron_right.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../auth/application/session.dart';
import '../../../cta/cta_page.dart';
import '../../../profile/data/user_profile_repository.dart';
import '../../models/place.dart';

/// 도장찍기 가능 거리 — 이 이상 멀면 버튼을 막는다.
const double _stampMaxDistanceInKm = 1.0;

/// "장소" 탭 리스트에서 카드를 탭하면 그 자리에서 커지며 보여주는 상세 카드.
///
/// 다른 페이지로 이동하는 게 아니라 [PlaceListCard]가 있던 자리에서 그대로
/// 확장되는 형태 — 리스트의 나머지 카드는 그대로 남아 있다.
/// 사진 3장 + 이 장소가 포함된 가이드북 개수 + 액션 버튼 영역으로 구성된다.
/// 버튼 영역은 로그인 여부에 따라 완전히 달라진다(Figma `placecard-ButtonContainer`):
/// - 로그인 상태: "내 가이드북에 추가"·"도장찍기" 버튼 2개가 나란히 노출된다.
///   "도장찍기"는 (1) 장소가 1km 이상 멀거나 (2) 마지막으로 도장 찍은 지
///   [stampCooldownDuration] 이내면 비활성 + 사유 텍스트로 바뀐다.
/// - 비로그인 상태: 버튼이 1개뿐이다 — 전체 너비의 "나도 도장찍기" CTA만 노출되고,
///   탭하면 [onStamp] 대신 로그인 유도 화면([CtaPage])으로 이동한다(거리/쿨다운
///   과 무관 — 로그인부터 시켜야 하니 항상 활성).
class PlaceDetailCard extends ConsumerWidget {
  const PlaceDetailCard(
    this.place, {
    super.key,
    this.onGuidebookTap,
    this.onAddToGuidebook,
    this.onStamp,
    this.onCollapse,
  });

  final Place place;
  final VoidCallback? onGuidebookTap;
  final VoidCallback? onAddToGuidebook;
  final VoidCallback? onStamp;

  /// 상단 헤더(이름·메타)를 탭했을 때 호출 — 다시 목록 카드로 접는 용도.
  final VoidCallback? onCollapse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isLoggedIn = ref.watch(sessionProvider) != null;
    final DateTime? lastStampedAt = ref.watch(lastStampedAtProvider);
    final String? stampDisabledReason =
        _stampDisabledReason(place, lastStampedAt);
    return Container(
      width: double.infinity,
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
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onCollapse,
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
                      Text(place.categoryName, style: AppTextStyles.placeMeta),
                      const SizedBox(width: 4),
                      Text('·', style: AppTextStyles.placeMeta),
                      const SizedBox(width: 4),
                      if (place.rating != null) ...<Widget>[
                        AppSvg(AppIcons.star,
                            size: 8, color: AppColors.textSecondary),
                        const SizedBox(width: 2),
                      ],
                      Text(_rating(place.rating), style: AppTextStyles.placeMeta),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(place.roadAddress, style: AppTextStyles.placeMeta),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _PhotoRow(place.photos),
          const SizedBox(height: 14),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onGuidebookTap,
            // Figma(`Frame 2610820`)에서 화살표는 텍스트 바로 뒤에 간격 없이
            // 붙는다 — Expanded로 텍스트를 늘려 화살표를 오른쪽 끝으로
            // 밀어내지 않는다.
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '이 장소가 포함된 가이드북 ${_formatCount(place.guidebookCount)}개',
                  style: AppTextStyles.placeMeta,
                ),
                const ChevronRight(length: 12),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (isLoggedIn)
            Row(
              children: <Widget>[
                Expanded(
                  child: PrimaryButton(
                    label: '내 가이드북에 추가',
                    onPressed: onAddToGuidebook,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PrimaryButton(
                    label: '도장찍기',
                    onPressed: stampDisabledReason == null ? onStamp : null,
                    subtitle: stampDisabledReason,
                  ),
                ),
              ],
            )
          else
            PrimaryButton(
              label: '나도 도장찍기',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const CtaPage()),
              ),
            ),
        ],
      ),
    );
  }

  /// 서버 응답엔 평점이 없다 — 리뷰 API 연동 전까지 null이면 '별점없음'.
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

/// "도장찍기" 버튼을 막아야 하면 그 사유 문구를, 아니면 null을 돌려준다.
/// 거리 조건이 쿨다운보다 먼저 걸린다 — 멀리 있으면 어차피 못 찍으니 굳이
/// 쿨다운까지 계산해서 알려줄 필요가 없다.
String? _stampDisabledReason(Place place, DateTime? lastStampedAt) {
  if (place.distanceInKm >= _stampMaxDistanceInKm) {
    return '너무 멀리있는 장소예요';
  }
  final int? remainingMinutes = stampCooldownRemainingMinutes(lastStampedAt);
  if (remainingMinutes == null) return null;
  return '$remainingMinutes분 뒤에 찍을 수 있어요';
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
