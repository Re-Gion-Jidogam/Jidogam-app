import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_mock_repository.dart';
import '../models/auth_state.dart';

/// 인증 바텀시트 플로우(단계 전환) 컨트롤러.
///
/// 필드 단위 검증·카운트다운·닉네임 중복확인은 각 step 위젯이 로컬로 처리하고,
/// 이 컨트롤러는 단계 전환과 목 저장소 호출만 담당한다.
class AuthFlowController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  AuthMockRepository get _repo => ref.read(authRepositoryProvider);

  void reset() => state = const AuthState();

  /// 이메일 입력 → 등록 여부로 로그인/회원가입 분기.
  Future<void> proceedFromEmail(String email) async {
    final String trimmed = email.trim();
    state = state.copyWith(isSubmitting: true, email: trimmed);
    final bool registered = await _repo.isEmailRegistered(trimmed);
    if (!registered) {
      await _repo.sendVerificationCode(trimmed);
    }
    state = state.copyWith(
      isSubmitting: false,
      step: registered ? AuthStep.login : AuthStep.verifyCode,
    );
  }

  Future<bool> login(String password) async {
    state = state.copyWith(isSubmitting: true);
    final bool ok = await _repo.login(email: state.email, password: password);
    state = state.copyWith(isSubmitting: false);
    return ok;
  }

  Future<void> submitCode(String code) async {
    state = state.copyWith(isSubmitting: true);
    await _repo.verifyCode(code);
    state = state.copyWith(isSubmitting: false, step: AuthStep.signupForm);
  }

  Future<void> submitSignup({
    required String nickname,
    required String password,
  }) async {
    state = state.copyWith(isSubmitting: true);
    await _repo.signup(
      email: state.email,
      nickname: nickname,
      password: password,
    );
    state = state.copyWith(
      isSubmitting: false,
      nickname: nickname,
      step: AuthStep.welcome,
    );
  }

  Future<void> confirmFindPassword() async {
    state = state.copyWith(isSubmitting: true);
    await _repo.sendTemporaryPassword(state.email);
    state = state.copyWith(isSubmitting: false, step: AuthStep.findPwSent);
  }

  // ── 단계 이동 ─────────────────────────────────────────────────
  void goToEmailEntry() => state = state.copyWith(step: AuthStep.emailEntry);
  void goToLogin() => state = state.copyWith(step: AuthStep.login);
  void goToFindPassword() =>
      state = state.copyWith(step: AuthStep.findPwConfirm);
}

final authFlowProvider =
    NotifierProvider<AuthFlowController, AuthState>(AuthFlowController.new);
