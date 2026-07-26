import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../application/auth_flow_controller.dart';

/// 비밀번호 찾기 — 이메일 확인.
class FindPasswordConfirmStep extends ConsumerWidget {
  const FindPasswordConfirmStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String email = ref.watch(authFlowProvider.select((s) => s.email));
    final bool submitting =
        ref.watch(authFlowProvider.select((s) => s.isSubmitting));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(email, style: AppTextStyles.title18),
                const SizedBox(height: 8),
                Text(
                  '위 메일이 맞나요?\n임시 비밀번호를 발급해드릴게요.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bannerSubtitle,
                ),
              ],
            ),
          ),
        ),
        PrimaryButton(
          label: '네, 맞아요',
          isLoading: submitting,
          onPressed: submitting
              ? null
              : () => ref.read(authFlowProvider.notifier).confirmFindPassword(),
        ),
      ],
    );
  }
}
