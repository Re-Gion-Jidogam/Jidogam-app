import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_svg.dart';
import '../../../../core/widgets/chevron_right.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';
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
///   [stampCooldownDuration] 이내면 비활성 + 사유 텍스트로 바뀐다. 이미 도장을
///   찍은 장소([Place.visitedDate]가 있음)면 두 번째 버튼이 "도장 지우기"
///   (빨강 아웃라인)로 바뀌고, 카드 우상단에 TRAVEL 도장 워터마크가 걸린다
///   (Figma `image 41`, [StampCard]와 같은 패턴).
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
    this.onRemoveStamp,
    this.onCollapse,
  });

  final Place place;
  final VoidCallback? onGuidebookTap;
  final VoidCallback? onAddToGuidebook;
  final VoidCallback? onStamp;

  /// 이미 도장을 찍은 장소에서 "도장 지우기"를 탭했을 때 호출.
  final VoidCallback? onRemoveStamp;

  /// 카드의 빈 여백(사진·가이드북·버튼처럼 자체 탭 영역을 가진 부분 제외)을
  /// 탭했을 때 호출 — 다시 목록 카드로 접는 용도. [PlaceListCard]가 카드
  /// 전체를 눌러 펼치는 것과 대칭이 되도록, 접기도 카드 전체(빈 여백 기준)를
  /// 누를 수 있게 한다.
  final VoidCallback? onCollapse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isLoggedIn = ref.watch(sessionProvider) != null;
    final DateTime? lastStampedAt = ref.watch(lastStampedAtProvider);
    final bool isStamped = place.visitedDate != null;
    final String? stampDisabledReason =
        _stampDisabledReason(place, lastStampedAt);
    // 카드의 패딩(여백)까지 포함해 전체를 눌러야 접히니, GestureDetector가
    // Container의 padding 바깥(가장 바깥)을 감싸야 한다 — padding 안쪽만
    // 감싸면 여백 부분은 제스처를 못 받는다. 사진·가이드북 로우·버튼처럼
    // 자기 자신의 GestureDetector를 가진 안쪽 영역은 제스처 아레나에서
    // 그 안쪽이 우선하므로 접힘으로 새지 않는다.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onCollapse,
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.cardShadow,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            if (isStamped)
              // 카드 우상단 모서리 밖으로 살짝 걸치는 TRAVEL 도장 워터마크
              // ([StampCard]와 동일한 패턴).
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
            _content(
                context, ref, isLoggedIn, isStamped, stampDisabledReason),
          ],
        ),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    WidgetRef ref,
    bool isLoggedIn,
    bool isStamped,
    String? stampDisabledReason,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // 접기는 바깥 GestureDetector(build 참고)가 담당하니, 여긴 순수
        // 표시용 — 별도 GestureDetector로 감쌀 필요 없다.
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
                    AppSvg(AppIcons.star,
                        size: 8, color: AppColors.textSecondary),
                    const SizedBox(width: 2),
                  ],
                  Text(_rating(place.rating), style: AppTextStyles.placeMeta),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                isStamped
                    ? '${place.roadAddress} · ${_formatVisitedDate(place.visitedDate!)}에 도장찍음'
                    : place.roadAddress,
                style: AppTextStyles.placeMeta,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _PhotoRow(place.photos),
        const SizedBox(height: 14),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onGuidebookTap,
          // Figma(`Frame 2610820`)는 화살표가 텍스트 바로 뒤에 간격 없이
          // 붙지만, 너무 붙어 보인다는 피드백으로 글자 반 개 정도(6px)
          // 공백을 뒀다 — Expanded로 텍스트를 늘려 화살표를 오른쪽 끝으로
          // 밀어내는 방식은 아니다(리스트 폭에 안 맞게 벌어짐).
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '이 장소가 포함된 가이드북 ${_formatCount(place.guidebookCount)}개',
                style: AppTextStyles.placeMeta,
              ),
              const SizedBox(width: 6),
              // 12px 텍스트 옆 화살표는 length 12가 아니라 8 — login_step.dart의
              // "비밀번호 찾기 >"와 같은 비율(같은 12px 메타 텍스트 기준).
              const ChevronRight(length: 8),
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
                child: isStamped
                    ? SecondaryButton(
                        label: '도장 지우기',
                        borderColor: AppColors.red300,
                        textColor: AppColors.red400,
                        onPressed: onRemoveStamp,
                      )
                    : PrimaryButton(
                        label: '도장찍기',
                        onPressed:
                            stampDisabledReason == null ? onStamp : null,
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
    );
  }

  /// [StampCard]의 더미 날짜 표기("2025. 5. 14")와 같은 형식.
  String _formatVisitedDate(DateTime d) => '${d.year}. ${d.month}. ${d.day}';

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
