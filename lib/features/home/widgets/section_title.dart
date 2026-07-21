import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/chevron_right.dart';

/// 섹션 헤더 — 제목 + 오른쪽 꺾쇠.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.onTap});

  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(title, style: AppTextStyles.title18),
          const SizedBox(
            width: 28,
            height: 28,
            child: Center(
              child: ChevronRight(length: 14, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
