import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';
import 'circle_back_button.dart';

/// 드래그로 높이를 조절하는 재사용 바텀시트 (지도 컨벤션).
///
/// 스냅 지점(peek / half / full) 사이를 드래그·스냅하며, grabber 핸들 +
/// 상단 라운드 + 반투명 블러 크롬을 제공한다. 콘텐츠는 [contentBuilder]가
/// 전달받은 [ScrollController]로 스크롤을 구동한다(스크롤 최상단에서 아래로
/// 끌면 시트가 축소).
class ResizableBottomSheet extends StatelessWidget {
  const ResizableBottomSheet({
    super.key,
    required this.contentBuilder,
    this.controller,
    this.minChildSize = 0.16,
    this.initialChildSize = 0.45,
    this.maxChildSize = 0.95,
    this.snapSizes = const <double>[0.45],
    this.title,
    this.onBack,
  });

  final Widget Function(BuildContext, ScrollController) contentBuilder;
  final DraggableScrollableController? controller;
  final double minChildSize;
  final double initialChildSize;
  final double maxChildSize;
  final List<double> snapSizes;
  final String? title;

  /// null이 아니면 좌상단에 원형 뒤로가기 버튼을 띄운다.
  final VoidCallback? onBack;

  static const double _radius = 20;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: controller,
      minChildSize: minChildSize,
      initialChildSize: initialChildSize,
      maxChildSize: maxChildSize,
      snap: true,
      snapSizes: snapSizes,
      builder: (BuildContext context, ScrollController scrollController) {
        return ClipRRect(
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(_radius)),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Color(0xCCF5F5F5), // rgba(245,245,245,0.8)
                border: Border(top: BorderSide(color: Color(0x1A000000))),
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(_radius)),
              ),
              child: Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      const SizedBox(height: 12),
                      Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0x4D000000),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      if (title != null) ...<Widget>[
                        const SizedBox(height: 18),
                        Text(title!, style: AppTextStyles.sheetTitle),
                      ],
                      const SizedBox(height: 18),
                      Expanded(
                          child: contentBuilder(context, scrollController)),
                    ],
                  ),
                  if (onBack != null)
                    Positioned(
                      left: 12,
                      top: 12,
                      child: CircleBackButton(onTap: onBack!),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
