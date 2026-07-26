import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../theme/app_text_styles.dart';
import 'app_svg.dart';

/// 지도감 공용 바텀시트 셸 (컨벤션 컴포넌트 256:4060).
///
/// 반투명 블러 배경 + 상단 라운드 + grabber 핸들 + (선택)좌상단 원형 뒤로가기
/// + 가운데 타이틀. 콘텐츠는 [child]로 주입한다. 높이는 상위(모달)에서 정한다.
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.showHandle = true,
    this.onBack,
  });

  final Widget child;
  final String? title;
  final bool showHandle;

  /// null이 아니면 좌상단 원형 뒤로가기 버튼을 노출.
  final VoidCallback? onBack;

  static const double _radius = 20;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(_radius)),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xCCF5F5F5), // rgba(245,245,245,0.8)
            border: Border.all(color: const Color(0x1A000000)),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(_radius)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Stack(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    if (showHandle) ...<Widget>[
                      Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0x4D000000),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                    if (title != null) ...<Widget>[
                      Text(title!, style: AppTextStyles.sheetTitle),
                      const SizedBox(height: 18),
                    ],
                    Expanded(child: child),
                  ],
                ),
                if (onBack != null)
                  Positioned(
                    left: 0,
                    top: 0,
                    child: _BackButton(onTap: onBack!),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 반투명 원형 뒤로가기 버튼 (흰 좌향 chevron).
class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0x33000000),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0x33FFFFFF)),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x1A000000),
                  offset: Offset(0, 4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: 2),
              // 원본 chevron('^')을 반시계 90° 회전 → 좌향('<').
              child: Transform.rotate(
                angle: -math.pi / 2,
                child: AppSvg(
                  AppIcons.chevronRight,
                  size: 14,
                  width: 14,
                  height: 14 * 8 / 15,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
