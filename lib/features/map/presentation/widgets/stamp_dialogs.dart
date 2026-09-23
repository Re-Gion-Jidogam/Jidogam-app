import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../profile/data/user_profile_repository.dart';

/// 확인 모달의 회색 본문 텍스트 스타일(Figma `#52534E` Regular 14) —
/// [AppTextStyles.sheetTitle](gray800·SemiBold14)을 Regular로 낮춰 재사용한다.
final TextStyle _messageStyle =
    AppTextStyles.sheetTitle.copyWith(fontWeight: FontWeight.w400);

/// "도장찍기" 확인 다이얼로그(Figma 341:7372). 확인하면 true를 반환한다.
Future<bool> showStampConfirmDialog(
  BuildContext context, {
  required String placeName,
}) async {
  final int cooldownMinutes = stampCooldownDuration.inMinutes;
  final bool? result = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.2),
    builder: (_) => _StampActionDialog(
      title: '도장찍기',
      confirmLabel: '도장찍기',
      confirmColor: AppColors.primary300,
      message: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text.rich(
            TextSpan(
              style: _messageStyle,
              children: <InlineSpan>[
                TextSpan(
                  text: placeName,
                  style: _messageStyle.copyWith(fontWeight: FontWeight.w600),
                ),
                const TextSpan(text: '에\n도장을 찍을까요?'),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Text(
            '다른 도장은 $cooldownMinutes분 후에 찍을 수 있어요.',
            style: _messageStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
  return result ?? false;
}

/// "도장 지우기" 확인 다이얼로그(Figma 341:7112). 확인하면 true를 반환한다.
Future<bool> showStampRemoveDialog(
  BuildContext context, {
  required String placeName,
}) async {
  final bool? result = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.2),
    builder: (_) => _StampActionDialog(
      title: '도장 지우기',
      confirmLabel: '도장 지우기',
      confirmColor: AppColors.red200,
      message: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            placeName,
            style: _messageStyle.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          Text('도장을 지울까요?', style: _messageStyle, textAlign: TextAlign.center),
          const SizedBox(height: 14),
          Text(
            '지운 후에는 복구할 수 없어요.',
            style: _messageStyle.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.red300,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
  return result ?? false;
}

/// "도전 취소" 확인 다이얼로그. 확인하면 true.
Future<bool> showChallengeCancelDialog(
  BuildContext context, {
  required String guidebookTitle,
}) async {
  final bool? result = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.2),
    builder: (_) => _StampActionDialog(
      title: '도전 취소',
      confirmLabel: '도전 취소',
      confirmColor: AppColors.red200,
      message: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            guidebookTitle,
            style: _messageStyle.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          Text('도전을 취소할까요?', style: _messageStyle, textAlign: TextAlign.center),
          const SizedBox(height: 14),
          Text(
            '다시 도전하면 달성 경험치가\n지금과 달라질 수 있어요.',
            style: _messageStyle.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.red300,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
  return result ?? false;
}

/// 리뷰 작성 중 이탈 확인 다이얼로그. "나가기"면 true.
Future<bool> showReviewDiscardDialog(BuildContext context) async {
  final bool? result = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.2),
    builder: (_) => _StampActionDialog(
      title: '리뷰쓰기',
      confirmLabel: '나가기',
      confirmColor: AppColors.red200,
      message: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('리뷰 작성을 그만둘까요?',
              style: _messageStyle, textAlign: TextAlign.center),
          const SizedBox(height: 14),
          Text(
            '지금 나가면 작성한 내용이 사라져요.',
            style: _messageStyle.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.red300,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
  return result ?? false;
}

/// 확인 다이얼로그 공통 셸(Figma `Modal Content/default`) — 문구·색만 바꿔 쓴다.
class _StampActionDialog extends StatelessWidget {
  const _StampActionDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.confirmColor,
  });

  final String title;
  final Widget message;
  final String confirmLabel;
  final Color confirmColor;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: double.infinity,
              height: 36,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Text(
                    title,
                    style: AppTextStyles.sheetTitle.copyWith(fontSize: 12),
                  ),
                  Positioned(
                    right: 0,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(context).pop(false),
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(
                          Icons.close,
                          size: 12,
                          color: AppColors.sheetTitle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            message,
            const SizedBox(height: 24),
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
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PrimaryButton(
                    label: confirmLabel,
                    color: confirmColor,
                    onPressed: () => Navigator.of(context).pop(true),
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
