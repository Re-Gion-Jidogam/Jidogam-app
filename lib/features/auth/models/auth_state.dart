/// 인증 바텀시트의 단계.
enum AuthStep {
  emailEntry, // 이메일 입력 (로그인 및 회원가입)
  login, // 로그인 (등록된 이메일)
  verifyCode, // 인증번호 (회원가입)
  signupForm, // 가입 폼 (닉네임/비번)
  welcome, // 가입 완료 (confetti)
  findPwConfirm, // 비밀번호 찾기 — 이메일 확인
  findPwSent, // 비밀번호 찾기 — 발송 완료
}

/// 인증 플로우 상태.
class AuthState {
  const AuthState({
    this.step = AuthStep.emailEntry,
    this.email = '',
    this.nickname = '',
    this.isSubmitting = false,
  });

  final AuthStep step;
  final String email;
  final String nickname;

  /// 비동기 처리(목 지연) 중 여부 — 버튼 로딩/중복탭 방지.
  final bool isSubmitting;

  AuthState copyWith({
    AuthStep? step,
    String? email,
    String? nickname,
    bool? isSubmitting,
  }) {
    return AuthState(
      step: step ?? this.step,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}
