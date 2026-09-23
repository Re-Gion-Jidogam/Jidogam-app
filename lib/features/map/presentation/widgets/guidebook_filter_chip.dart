import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// "가이드북" 탭 필터 알약(Figma `order-badge`) — 아이콘 + 라벨의 아웃라인 칩.
/// "출판됨"/"비공개"처럼 "도전중인 가이드북" 목록을 좁히는 용도.
///
/// [icon]은 위젯을 그대로 받는다 — Figma의 "출판됨" 체크 아이콘은 원본
/// SVG(11.25×6)가 옆으로 납작해서 14×14로 강제로 맞추면 "비공개" 옆에서
/// 유독 크고 두꺼워 보인다. 두 아이콘의 굵기·크기를 맞추려고 "출판됨"
/// 쪽은 두께가 균일한 [Icons.check]를 쓴다(SVG는 그대로면 부자연스러움).
class GuidebookFilterChip extends StatelessWidget {
  const GuidebookFilterChip({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.selected = false,
  });

  final Widget icon;
  final String label;
  final VoidCallback? onTap;

  /// 선택 상태(옅은 초록). Figma엔 없지만 필터 적용 여부 표시용으로 추가.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary300.withValues(alpha: 0.12) : null,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected ? AppColors.primary300 : AppColors.gray400,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(width: 14, height: 14, child: Center(child: icon)),
            const SizedBox(width: 4),
            Text(label, style: AppTextStyles.helper),
          ],
        ),
      ),
    );
  }
}
