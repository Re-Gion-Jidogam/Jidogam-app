import 'package:flutter/material.dart';

/// 지도감 디자인 시스템 색상 토큰.
///
/// Figma 변수(`gray/*`, `primary/*`)를 그대로 옮긴 원시 팔레트와,
/// 화면에서 의미 단위로 쓰는 시맨틱 별칭을 함께 제공한다.
abstract final class AppColors {
  // ── Raw palette (Figma variables) ─────────────────────────────
  static const Color gray900 = Color(0xFF262624);
  static const Color gray800 = Color(0xFF52534E);
  static const Color gray700 = Color(0xFF7C7F76);
  static const Color gray600 = Color(0xFFA1A499);
  static const Color gray300 = Color(0xFFE6E8DF);
  static const Color gray200 = Color(0xFFF2F4ED);
  static const Color gray0 = Color(0xFFFFFFFF);

  static const Color primary300 = Color(0xFFA2CD20);
  static const Color primary400 = Color(0xFF7EA310);

  static const Color red200 = Color(0xFFF03E31);
  static const Color red300 = Color(0xFFDC1D10);
  static const Color red400 = Color(0xFFBF1004);

  // ── Semantic aliases ──────────────────────────────────────────
  /// 스크린 배경(#F5F5F5).
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = gray0;

  static const Color textPrimary = gray900;
  static const Color textSecondary = gray700;
  static const Color textMuted = gray600;

  static const Color border = gray200;

  /// 바텀시트 타이틀 색상.
  static const Color sheetTitle = gray800;

  /// 입력 필드 포커스/유효 상태(초록) 테두리.
  static const Color fieldFocus = primary300;

  /// 입력 필드 에러 테두리.
  static const Color fieldError = red200;

  /// 에러 헬퍼 텍스트.
  static const Color errorText = red400;

  /// BNB 활성 탭 색상.
  static const Color navActive = primary400;

  /// BNB 비활성 탭 색상.
  static const Color navInactive = gray600;

  // ── Effects ───────────────────────────────────────────────────
  /// Figma `commonShadow` — drop shadow 0/4, blur 20, black 10%.
  static const List<BoxShadow> commonShadow = <BoxShadow>[
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 4),
      blurRadius: 20,
    ),
  ];

  /// placeCard / 카드 그림자 — drop shadow 0/4, blur 10, black 10%.
  static const List<BoxShadow> cardShadow = <BoxShadow>[
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 4),
      blurRadius: 10,
    ),
  ];
}
