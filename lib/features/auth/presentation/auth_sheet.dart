import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_bottom_sheet.dart';
import '../application/auth_flow_controller.dart';
import '../models/auth_state.dart';
import 'steps/email_entry_step.dart';
import 'steps/find_password_confirm_step.dart';
import 'steps/find_password_sent_step.dart';
import 'steps/login_step.dart';
import 'steps/signup_form_step.dart';
import 'steps/verify_code_step.dart';
import 'steps/welcome_step.dart';
import 'widgets/exit_signup_dialog.dart';

/// 로그인/회원가입 바텀시트를 띄운다. 열기 전 플로우를 첫 단계로 초기화한다.
Future<void> showAuthSheet(BuildContext context, WidgetRef ref) {
  ref.read(authFlowProvider.notifier).reset();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x66000000), // dimmer
    builder: (_) => const AuthSheet(),
  );
}

/// 단계에 따라 셸 타이틀/콘텐츠/뒤로가기를 스위칭하는 인증 시트.
class AuthSheet extends ConsumerStatefulWidget {
  const AuthSheet({super.key});

  @override
  ConsumerState<AuthSheet> createState() => _AuthSheetState();
}

class _AuthSheetState extends ConsumerState<AuthSheet> {
  String _titleFor(AuthStep step) => switch (step) {
        AuthStep.emailEntry => '로그인 및 회원가입',
        AuthStep.login => '로그인',
        AuthStep.verifyCode => '회원가입',
        AuthStep.signupForm => '회원가입',
        AuthStep.welcome => '가입완료',
        AuthStep.findPwConfirm => '비밀번호 찾기',
        AuthStep.findPwSent => '비밀번호 찾기',
      };

  Widget _contentFor(AuthStep step) => switch (step) {
        AuthStep.emailEntry => const EmailEntryStep(),
        AuthStep.login => const LoginStep(),
        AuthStep.verifyCode => const VerifyCodeStep(),
        AuthStep.signupForm => const SignupFormStep(),
        AuthStep.welcome => const WelcomeStep(),
        AuthStep.findPwConfirm => const FindPasswordConfirmStep(),
        AuthStep.findPwSent => const FindPasswordSentStep(),
      };

  Future<void> _handleBack(AuthStep step) async {
    final AuthFlowController notifier = ref.read(authFlowProvider.notifier);
    switch (step) {
      case AuthStep.emailEntry:
      case AuthStep.welcome:
        Navigator.of(context).pop();
      case AuthStep.login:
      case AuthStep.verifyCode:
        notifier.goToEmailEntry();
      case AuthStep.findPwConfirm:
      case AuthStep.findPwSent:
        notifier.goToLogin();
      case AuthStep.signupForm:
        await _confirmExitAndPop();
    }
  }

  /// 회원가입 중단 다이얼로그 → 중단 선택 시 시트 닫기.
  Future<void> _confirmExitAndPop() async {
    final NavigatorState navigator = Navigator.of(context);
    final bool abort = await ExitSignupDialog.show(context);
    if (abort) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final AuthStep step = ref.watch(authFlowProvider.select((s) => s.step));
    final MediaQueryData media = MediaQuery.of(context);
    final double keyboard = media.viewInsets.bottom;
    final double bottomPad = keyboard > 0 ? keyboard : media.padding.bottom;
    final double height =
        (media.size.height - media.padding.top - 8 - bottomPad)
            .clamp(320.0, media.size.height);

    return PopScope(
      canPop: step != AuthStep.signupForm,
      onPopInvokedWithResult: (bool didPop, _) {
        if (didPop || step != AuthStep.signupForm) return;
        _confirmExitAndPop();
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPad),
        child: SizedBox(
          height: height,
          child: AppBottomSheet(
            title: _titleFor(step),
            onBack: () => _handleBack(step),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: _contentFor(step),
            ),
          ),
        ),
      ),
    );
  }
}
