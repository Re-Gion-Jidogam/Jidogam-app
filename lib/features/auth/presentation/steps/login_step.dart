import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/chevron_right.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../application/auth_flow_controller.dart';
import '../auth_actions.dart';

/// 로그인 (등록된 이메일). 이메일 고정 + 비밀번호.
class LoginStep extends ConsumerStatefulWidget {
  const LoginStep({super.key});

  @override
  ConsumerState<LoginStep> createState() => _LoginStepState();
}

class _LoginStepState extends ConsumerState<LoginStep> {
  late final TextEditingController _emailController;
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController =
        TextEditingController(text: ref.read(authFlowProvider).email);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final bool ok =
        await ref.read(authFlowProvider.notifier).login(_passwordController.text);
    if (!mounted || !ok) return;
    completeAuth(
      context,
      ref,
      email: ref.read(authFlowProvider).email,
      nickname: '',
      message: '로그인되었습니다.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool submitting =
        ref.watch(authFlowProvider.select((s) => s.isSubmitting));
    final bool canSubmit =
        _passwordController.text.isNotEmpty && !submitting;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AppTextField(
          controller: _emailController,
          hint: '이메일',
          enabled: false,
        ),
        const SizedBox(height: 8),
        AppTextField(
          controller: _passwordController,
          hint: '비밀번호',
          obscureText: true,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) {
            if (canSubmit) _submit();
          },
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => ref.read(authFlowProvider.notifier).goToFindPassword(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('비밀번호 찾기', style: AppTextStyles.fieldTrailing),
                  const SizedBox(width: 2),
                  const ChevronRight(length: 8, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
        ),
        const Spacer(),
        PrimaryButton(
          label: '로그인',
          isLoading: submitting,
          onPressed: canSubmit ? _submit : null,
        ),
      ],
    );
  }
}
