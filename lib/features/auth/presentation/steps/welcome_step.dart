import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../application/auth_flow_controller.dart';
import '../auth_actions.dart';
import '../widgets/confetti_overlay.dart';

/// 가입 완료 — confetti + 환영 문구.
class WelcomeStep extends ConsumerWidget {
  const WelcomeStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String email = ref.watch(authFlowProvider.select((s) => s.email));
    final String nickname =
        ref.watch(authFlowProvider.select((s) => s.nickname));

    return Stack(
      children: <Widget>[
        const Positioned.fill(child: ConfettiOverlay()),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text('🥳', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 16),
                    Text.rich(
                      TextSpan(
                        children: <InlineSpan>[
                          const TextSpan(text: '환영해요 '),
                          TextSpan(
                            text: nickname,
                            style: TextStyle(color: AppColors.primary400),
                          ),
                          const TextSpan(text: '님!'),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.title18,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '이제 여행을 떠나볼까요?',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bannerSubtitle,
                    ),
                  ],
                ),
              ),
            ),
            PrimaryButton(
              label: '시작하기',
              onPressed: () => completeAuth(
                context,
                ref,
                email: email,
                nickname: nickname,
                message: '환영합니다!',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
