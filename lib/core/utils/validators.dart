/// 공용 입력 검증 유틸.
final RegExp _emailRegExp = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

bool isValidEmail(String value) => _emailRegExp.hasMatch(value.trim());

/// 비밀번호: 8자 이상.
bool isValidPassword(String value) => value.length >= 8;

/// 닉네임: 2~15자.
bool isValidNicknameLength(String value) {
  final int len = value.runes.length;
  return len >= 2 && len <= 15;
}
