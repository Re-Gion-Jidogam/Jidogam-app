import 'package:flutter/widgets.dart';

import 'app_colors.dart';

/// Pretendard 기반 타이포그래피 토큰.
///
/// Figma 텍스트 스펙을 이름 있는 스타일로 정리한다. 색상이 문맥에 따라
/// 달라지는 경우(카드 위 흰 글씨 등)는 `.copyWith(color:)`로 덮어쓴다.
abstract final class AppTextStyles {
  static const String _family = 'Pretendard';

  static const TextStyle _base = TextStyle(
    fontFamily: _family,
    color: AppColors.textPrimary,
    height: 1.2,
    leadingDistribution: TextLeadingDistribution.even,
  );

  // ── Titles ────────────────────────────────────────────────────
  /// 섹션 타이틀 / 배너 타이틀 — Bold 18.
  static final TextStyle title18 = _base.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  /// 가이드북 카드 제목 — Bold 18, line-height 1.4 (흰색·그림자는 위젯에서).
  static final TextStyle cardTitle18 = _base.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.4,
  );

  /// placeCard 제목 — Bold 14.
  static final TextStyle placeTitle14 = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  // ── Body / meta ───────────────────────────────────────────────
  /// 배너 서브텍스트 — Regular 12, muted.
  static final TextStyle bannerSubtitle = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  /// placeCard 메타(카테고리·평점·주소) — Regular 12, secondary.
  static final TextStyle placeMeta = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// 평점 배지 숫자 — SemiBold 14.
  static final TextStyle ratingBadge = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  // ── Card overlay meta (white on image) ────────────────────────
  /// 카드 오버레이 메타 — Medium 10.
  static final TextStyle cardMetaMedium = _base.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  /// 카드 오버레이 강조 메타 — Bold 10.
  static final TextStyle cardMetaBold = _base.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  /// 카드 오버레이 평점 — Regular 10.
  static final TextStyle cardMetaRegular = _base.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 1.2,
  );

  // ── Navigation ────────────────────────────────────────────────
  /// BNB 라벨 — SemiBold 8.
  static final TextStyle navLabel = _base.copyWith(
    fontSize: 8,
    fontWeight: FontWeight.w600,
  );

  // ── Bottom sheet / forms ──────────────────────────────────────
  /// 바텀시트 타이틀 — SemiBold 14, gray800.
  static final TextStyle sheetTitle = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.sheetTitle,
  );

  /// 입력값 텍스트 — Medium 14, gray900.
  static final TextStyle field = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  /// 입력 placeholder — Medium 14, gray600.
  static final TextStyle fieldHint = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  /// 카운터/트레일링 — Medium 12, gray600.
  static final TextStyle fieldTrailing = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  /// 헬퍼/에러 텍스트 — Medium 12 (색은 상태별로 지정).
  static final TextStyle helper = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  /// CTA 버튼 라벨 — SemiBold 14, white.
  static final TextStyle button = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.gray0,
  );
}
