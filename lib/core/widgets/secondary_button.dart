import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// 보조 CTA 버튼 (높이 45, 라운드 12) — 흰 배경 + primary 테두리.
///
/// [PrimaryButton]과 짝을 이뤄 나란히 쓰는 보조 액션(예: "내 가이드북에 추가")용.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onPressed : null,
      child: Container(
        height: 45,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: enabled
                ? AppColors.primary300
                : AppColors.primary300.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.button.copyWith(
            color: enabled
                ? AppColors.primary400
                : AppColors.primary400.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}
