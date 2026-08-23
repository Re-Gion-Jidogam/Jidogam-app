import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/chevron_right.dart';

/// "가이드북" 탭 상단의 프로모 카드 2개(Figma "인기 가이드북"/"지나가던사람님을
/// 기다리는 곳") — 배경 위에 라벨 + 화살표를 좌하단에 얹는다.
///
/// [MapSearchField] 아래에서 [Row]에 두 개씩 나란히 쓰는 걸 전제로, 자체가
/// 이미 [Expanded]다.
class GuidebookPromoCard extends StatelessWidget {
  const GuidebookPromoCard({
    super.key,
    required this.label,
    this.backgroundAsset,
    this.backgroundColor = AppColors.surface,
    this.backgroundAlignment = Alignment.bottomRight,
    this.onTap,
  });

  /// 줄바꿈이 필요하면 `\n`을 그대로 넣는다("지나가던사람님을\n기다리는 곳").
  final String label;

  /// 배경 일러스트 — 없으면 [backgroundColor]만 깐다(임시 배경).
  final String? backgroundAsset;
  final Color backgroundColor;
  final Alignment backgroundAlignment;
  final VoidCallback? onTap;

  static const double _height = 110;
  static const double _radius = 12;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: _height,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(_radius),
          ),
          child: Stack(
            children: <Widget>[
              if (backgroundAsset != null)
                Positioned.fill(
                  child: Image.asset(
                    backgroundAsset!,
                    fit: BoxFit.cover,
                    alignment: backgroundAlignment,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        label,
                        style: AppTextStyles.button
                            .copyWith(color: AppColors.textPrimary, height: 1.5),
                      ),
                      const SizedBox(width: 4),
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: Center(
                          child: ChevronRight(length: 11.25),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
