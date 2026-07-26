import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../application/auth_flow_controller.dart';
import '../../data/auth_mock_repository.dart';

/// 회원가입 — 인증번호 입력 (mm:ss 카운트다운).
class VerifyCodeStep extends ConsumerStatefulWidget {
  const VerifyCodeStep({super.key});

  @override
  ConsumerState<VerifyCodeStep> createState() => _VerifyCodeStepState();
}

class _VerifyCodeStepState extends ConsumerState<VerifyCodeStep> {
  final TextEditingController _codeController = TextEditingController();
  static const int _initialSeconds = 300; // 5:00
  int _seconds = _initialSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _seconds = _initialSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (!mounted) return;
      if (_seconds <= 0) {
        t.cancel();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  void _resend() {
    ref
        .read(authRepositoryProvider)
        .sendVerificationCode(ref.read(authFlowProvider).email);
    _startCountdown();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    ref.read(authFlowProvider.notifier).submitCode(_codeController.text.trim());
  }

  String get _mmss {
    final String m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final String s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final String email = ref.watch(authFlowProvider.select((s) => s.email));
    final bool submitting =
        ref.watch(authFlowProvider.select((s) => s.isSubmitting));
    final bool canSubmit =
        _codeController.text.trim().length == 6 && !submitting;

    final Widget trailing = _seconds > 0
        ? Text(
            _mmss,
            style: AppTextStyles.fieldTrailing
                .copyWith(color: AppColors.primary400),
          )
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _resend,
            child: Text(
              '재전송',
              style:
                  AppTextStyles.helper.copyWith(color: AppColors.primary400),
            ),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 8),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('반가워요!',
                  style: AppTextStyles.title18.copyWith(fontSize: 16)),
              const SizedBox(height: 12),
              Text(email, style: AppTextStyles.title18),
              const SizedBox(height: 4),
              Text(
                '위 메일로 보낸 인증번호를 입력해주세요',
                textAlign: TextAlign.center,
                style: AppTextStyles.bannerSubtitle,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        AppTextField(
          controller: _codeController,
          hint: '인증번호',
          keyboardType: TextInputType.number,
          trailing: trailing,
          onChanged: (_) => setState(() {}),
        ),
        const Spacer(),
        PrimaryButton(
          label: '계속',
          isLoading: submitting,
          onPressed: canSubmit ? _submit : null,
        ),
      ],
    );
  }
}
