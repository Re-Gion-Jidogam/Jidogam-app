import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// "회원가입 중단" 확인 다이얼로그 (370:11182). 중단 선택 시 true 반환.
class ExitSignupDialog extends StatelessWidget {
  const ExitSignupDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (_) => const ExitSignupDialog(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                const SizedBox(width: 24),
                Expanded(
                  child: Text(
                    '회원가입 중단',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.title18.copyWith(fontSize: 16),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).pop(false),
                  child: const Icon(Icons.close,
                      size: 24, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              '정말로 회원가입을 중단할까요?',
              textAlign: TextAlign.center,
              style: AppTextStyles.field.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              '작성한 내용은 저장되지 않아요.',
              textAlign: TextAlign.center,
              style: AppTextStyles.helper.copyWith(color: AppColors.errorText),
            ),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).pop(false),
                    child: Container(
                      height: 45,
                      alignment: Alignment.center,
                      child: Text(
                        '취소',
                        style: AppTextStyles.button
                            .copyWith(color: AppColors.textMuted),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).pop(true),
                    child: Container(
                      height: 45,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.red200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('가입 중단', style: AppTextStyles.button),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
