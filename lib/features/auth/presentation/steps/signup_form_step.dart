import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../application/auth_flow_controller.dart';

/// 회원가입 폼 — 닉네임(중복확인)·비밀번호·비밀번호 확인.
class SignupFormStep extends ConsumerStatefulWidget {
  const SignupFormStep({super.key});

  @override
  ConsumerState<SignupFormStep> createState() => _SignupFormStepState();
}

class _SignupFormStepState extends ConsumerState<SignupFormStep> {
  late final TextEditingController _emailController;
  final TextEditingController _nickController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _pwConfirmController = TextEditingController();

  /// 목: 사용 중으로 취급하는 닉네임.
  static const Set<String> _taken = <String>{'admin', '관리자', '지도감'};

  @override
  void initState() {
    super.initState();
    _emailController =
        TextEditingController(text: ref.read(authFlowProvider).email);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nickController.dispose();
    _pwController.dispose();
    _pwConfirmController.dispose();
    super.dispose();
  }

  (FieldStatus, String?) get _nickState {
    final String n = _nickController.text.trim();
    if (n.isEmpty) return (FieldStatus.normal, null);
    if (!isValidNicknameLength(n)) {
      return (FieldStatus.error, '닉네임은 2~15자로 입력해주세요');
    }
    if (_taken.contains(n)) return (FieldStatus.error, '이미 사용 중인 닉네임입니다');
    return (FieldStatus.valid, '사용 가능한 닉네임입니다');
  }

  (FieldStatus, String?) get _pwState {
    final String p = _pwController.text;
    if (p.isEmpty) return (FieldStatus.normal, null);
    if (!isValidPassword(p)) return (FieldStatus.error, '비밀번호는 8자 이상이어야 해요');
    return (FieldStatus.valid, null);
  }

  (FieldStatus, String?) get _pwConfirmState {
    final String c = _pwConfirmController.text;
    if (c.isEmpty) return (FieldStatus.normal, null);
    if (c != _pwController.text) {
      return (FieldStatus.error, '비밀번호가 일치하지 않습니다');
    }
    return (FieldStatus.valid, null);
  }

  bool get _canSubmit {
    final (FieldStatus ns, _) = _nickState;
    return ns == FieldStatus.valid &&
        isValidPassword(_pwController.text) &&
        _pwConfirmController.text == _pwController.text;
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    ref.read(authFlowProvider.notifier).submitSignup(
          nickname: _nickController.text.trim(),
          password: _pwController.text,
        );
  }

  void _rebuild(String _) => setState(() {});

  @override
  Widget build(BuildContext context) {
    final bool submitting =
        ref.watch(authFlowProvider.select((s) => s.isSubmitting));
    final (FieldStatus nickStatus, String? nickHelper) = _nickState;
    final (FieldStatus pwStatus, String? pwHelper) = _pwState;
    final (FieldStatus pwcStatus, String? pwcHelper) = _pwConfirmState;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AppTextField(
                  controller: _emailController,
                  hint: '이메일',
                  enabled: false,
                  trailing: Text('인증완료', style: AppTextStyles.fieldTrailing),
                ),
                const SizedBox(height: 8),
                AppTextField(
                  controller: _nickController,
                  hint: '닉네임',
                  maxLength: 15,
                  status: nickStatus,
                  helper: nickHelper,
                  onChanged: _rebuild,
                ),
                const SizedBox(height: 8),
                AppTextField(
                  controller: _pwController,
                  hint: '비밀번호',
                  obscureText: true,
                  maxLength: 20,
                  status: pwStatus,
                  helper: pwHelper,
                  onChanged: _rebuild,
                ),
                const SizedBox(height: 8),
                AppTextField(
                  controller: _pwConfirmController,
                  hint: '비밀번호 확인',
                  obscureText: true,
                  maxLength: 20,
                  status: pwcStatus,
                  helper: pwcHelper,
                  onChanged: _rebuild,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          label: '가입하기',
          isLoading: submitting,
          onPressed: _canSubmit && !submitting ? _submit : null,
        ),
      ],
    );
  }
}
