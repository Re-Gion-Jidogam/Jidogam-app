import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';

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
  });

  final Widget Function(BuildContext, ScrollController) contentBuilder;
  final DraggableScrollableController? controller;
  final double minChildSize;
  final double initialChildSize;
  final double maxChildSize;
  final List<double> snapSizes;
  final String? title;

  static const double _radius = 20;

  /// grabber/헤더를 끌 때 스냅할 지점들(작은 값부터).
  List<double> get _snapPoints =>
      (<double>{minChildSize, ...snapSizes, maxChildSize}.toList())..sort();

  /// 헤더(손잡이/제목) 드래그 — [DraggableScrollableSheet]는 안쪽 스크롤로만
  /// 리사이즈되므로, 스크롤 영역 밖(손잡이 막대)을 잡아도 시트가 움직이도록
  /// 컨트롤러 크기를 직접 조절한다.
  void _onDrag(BuildContext context, double? deltaY) {
    if (controller == null || deltaY == null) return;
    final double height = MediaQuery.of(context).size.height;
    final double next =
        (controller!.size - deltaY / height).clamp(minChildSize, maxChildSize);
    controller!.jumpTo(next);
  }

  /// 드래그를 놓으면 가장 가까운 스냅 지점으로(빠르게 튕기면 그 방향으로).
  void _onDragEnd(double? velocityY) {
    if (controller == null) return;
    final List<double> points = _snapPoints;
    final double current = controller!.size;
    double target = points.reduce((double a, double b) =>
        (a - current).abs() <= (b - current).abs() ? a : b);
    if (velocityY != null && velocityY.abs() > 300) {
      target = velocityY < 0
          ? points.firstWhere((double p) => p > current, orElse: () => points.last)
          : points.lastWhere((double p) => p < current, orElse: () => points.first);
    }
    controller!.animateTo(
      target,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

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
        // 손잡이 + (있으면) 제목 — 스크롤 밖 영역. 여기를 잡아도 끌리게 한다.
        final Widget header = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragUpdate: (DragUpdateDetails d) =>
              _onDrag(context, d.primaryDelta),
          onVerticalDragEnd: (DragEndDetails d) =>
              _onDragEnd(d.primaryVelocity),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
            ],
          ),
        );

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
              child: Column(
                children: <Widget>[
                  header,
                  Expanded(child: contentBuilder(context, scrollController)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
