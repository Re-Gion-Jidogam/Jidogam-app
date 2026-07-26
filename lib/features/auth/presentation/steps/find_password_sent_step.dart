import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../application/auth_flow_controller.dart';

/// 비밀번호 찾기 — 임시 비밀번호 발송 완료.
class FindPasswordSentStep extends ConsumerWidget {
  const FindPasswordSentStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String email = ref.watch(authFlowProvider.select((s) => s.email));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary300, width: 2),
                  ),
                  child: const Icon(Icons.check,
                      color: AppColors.primary400, size: 32),
                ),
                const SizedBox(height: 16),
                Text(email, style: AppTextStyles.title18),
                const SizedBox(height: 4),
                Text('임시 비밀번호를 보냈어요.', style: AppTextStyles.bannerSubtitle),
              ],
            ),
          ),
        ),
        PrimaryButton(
          label: '로그인 하기',
          onPressed: () => ref.read(authFlowProvider.notifier).goToLogin(),
        ),
      ],
    );
  }
}
