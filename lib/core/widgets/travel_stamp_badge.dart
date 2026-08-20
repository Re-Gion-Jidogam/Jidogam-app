import 'package:flutter/material.dart';

import '../constants/app_assets.dart';

/// "TRAVEL" 도장 아트웍 — 피그마 스탬프 이미지(assets/images/travel_stamp.png)를
/// 그대로 렌더한다. 원본 비율(250:211)을 유지한 채 [width]만 지정하면 된다.
///
/// [StampCard]의 카드 코너 워터마크와 CTA 화면의 회전 타일 배경에서 함께 쓴다.
class TravelStampBadge extends StatelessWidget {
  const TravelStampBadge({super.key, this.width = 92, this.opacity = 1});

  /// 렌더 폭(dp). 높이는 원본 비율(250:211)에 맞춰 자동 계산된다.
  final double width;

  /// 불투명도 — 카드 워터마크는 은은하게, CTA 배경 타일은 원본 그대로 쓸 수 있도록 조절.
  final double opacity;

  static const double _aspectRatio = 211 / 250;

  @override
  Widget build(BuildContext context) {
    final Widget image = Image.asset(
      AppImages.travelStamp,
      width: width,
      height: width * _aspectRatio,
      fit: BoxFit.contain,
    );
    return opacity >= 1 ? image : Opacity(opacity: opacity, child: image);
  }
}
