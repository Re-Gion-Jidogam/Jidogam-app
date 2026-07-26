import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 인증 목(mock) 저장소.
///
/// 백엔드 미연동 단계라 하드코딩 규칙으로 분기한다. 추후 실제 API로
/// 교체할 때 이 클래스만 구현체를 바꾸면 UI/컨트롤러는 유지된다.
class AuthMockRepository {
  const AuthMockRepository();

  /// 이미 등록된 것으로 취급하는 이메일(→ 로그인 분기).
  static const Set<String> _registeredEmails = <String>{
    'example@example.com',
    'test@example.com',
    'hello@jidogam.app',
  };

  /// 사용 중(불가)으로 취급하는 닉네임.
  static const Set<String> _takenNicknames = <String>{
    'admin',
    '관리자',
    '지도감',
  };

  Future<bool> isEmailRegistered(String email) async {
    await _delay();
    return _registeredEmails.contains(email.trim().toLowerCase());
  }

  Future<void> sendVerificationCode(String email) => _delay();

  /// 6자리 숫자면 통과(목).
  Future<bool> verifyCode(String code) async {
    await _delay();
    return RegExp(r'^\d{6}$').hasMatch(code);
  }

  Future<bool> isNicknameAvailable(String nickname) async {
    await _delay(300);
    return !_takenNicknames.contains(nickname.trim());
  }

  /// 비밀번호가 비어있지 않으면 성공(목).
  Future<bool> login({required String email, required String password}) async {
    await _delay();
    return password.isNotEmpty;
  }

  Future<void> signup({
    required String email,
    required String nickname,
    required String password,
  }) =>
      _delay();

  Future<void> sendTemporaryPassword(String email) => _delay();

  Future<void> _delay([int milliseconds = 600]) =>
      Future<void>.delayed(Duration(milliseconds: milliseconds));
}

final authRepositoryProvider = Provider<AuthMockRepository>(
  (ref) => const AuthMockRepository(),
);
