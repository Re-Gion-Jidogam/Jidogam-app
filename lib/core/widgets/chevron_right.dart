import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../constants/app_assets.dart';
import '../theme/app_colors.dart';
import 'app_svg.dart';

/// 오른쪽 방향 꺾쇠(`>`).
///
/// Figma 원본 벡터는 위로 향한 `^`(15×8) 이며, 디자인에서 90° 회전으로
/// `>` 를 만든다. 동일하게 시계방향 90° 회전해 렌더링한다.
/// [length]는 완성된 `>` 의 세로 높이(px).
class ChevronRight extends StatelessWidget {
  const ChevronRight({
    super.key,
    this.length = 14,
    this.color = AppColors.textMuted,
  });

  final double length;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: math.pi / 2,
      child: AppSvg(
        AppIcons.chevronRight,
        size: length,
        width: length,
        height: length * 8 / 15,
        color: color,
      ),
    );
  }
}
