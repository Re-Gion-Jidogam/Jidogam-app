import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../application/auth_flow_controller.dart';

/// 1단계 — 이메일 입력 (로그인 및 회원가입).
class EmailEntryStep extends ConsumerStatefulWidget {
  const EmailEntryStep({super.key});

  @override
  ConsumerState<EmailEntryStep> createState() => _EmailEntryStepState();
}

class _EmailEntryStepState extends ConsumerState<EmailEntryStep> {
  final TextEditingController _controller = TextEditingController();
  FieldStatus _status = FieldStatus.normal;
  String? _helper;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final String email = _controller.text.trim();
    if (!isValidEmail(email)) {
      setState(() {
        _status = FieldStatus.error;
        _helper = '잘못된 이메일입니다';
      });
      return;
    }
    FocusScope.of(context).unfocus();
    ref.read(authFlowProvider.notifier).proceedFromEmail(email);
  }

  @override
  Widget build(BuildContext context) {
    final bool submitting =
        ref.watch(authFlowProvider.select((s) => s.isSubmitting));
    final bool canSubmit = _controller.text.trim().isNotEmpty && !submitting;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AppTextField(
          controller: _controller,
          hint: '이메일',
          maxLength: 50,
          keyboardType: TextInputType.emailAddress,
          status: _status,
          helper: _helper,
          onChanged: (_) {
            setState(() {
              if (_status == FieldStatus.error) {
                _status = FieldStatus.normal;
                _helper = null;
              }
            });
          },
          onSubmitted: (_) {
            if (canSubmit) _submit();
          },
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
