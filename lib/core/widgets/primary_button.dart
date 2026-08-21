import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// 초록 CTA 버튼 (높이 45, 라운드 12).
///
/// [onPressed]가 null이거나 [isLoading]이면 비활성(연한 초록) 상태.
/// [subtitle]을 주면(비활성일 때만 노출) 회색 배경 + 라벨 아래 사유 텍스트로
/// 바뀐다 — "폼이 아직 안 채워짐" 같은 일반 비활성과 달리 "너무 멀리있는
/// 장소예요"처럼 이유를 설명해야 하는 상태용.
/// [color]로 채움색을 바꿀 수 있다 — 확인 다이얼로그의 "도장 지우기"처럼
/// 같은 버튼 모양에 위험(빨강) 색만 필요한 경우 새 위젯 없이 재사용한다.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.subtitle,
    this.color = AppColors.primary300,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null && !isLoading;
    final bool hasReason = !enabled && subtitle != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onPressed : null,
      child: Container(
        height: 45,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled
              ? color
              : hasReason
                  ? AppColors.gray300
                  : color.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : hasReason
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        label,
                        style: AppTextStyles.button
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      Text(
                        subtitle!,
                        style: AppTextStyles.cardMetaRegular
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  )
                : Text(label, style: AppTextStyles.button),
      ),
    );
  }
}
