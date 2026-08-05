import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 로그인 세션(목).
class AppSession {
  const AppSession({required this.email, required this.nickname});

  final String email;
  final String nickname;
}

/// 앱 전역 로그인 세션. null이면 비로그인.
class SessionController extends Notifier<AppSession?> {
  @override
  AppSession? build() => null;

  void signIn({required String email, required String nickname}) {
    state = AppSession(
      email: email,
      nickname: nickname.isEmpty ? _nameFromEmail(email) : nickname,
    );
  }

  void signOut() => state = null;

  String _nameFromEmail(String email) {
    final int at = email.indexOf('@');
    return at > 0 ? email.substring(0, at) : email;
  }
}

final sessionProvider =
    NotifierProvider<SessionController, AppSession?>(SessionController.new);
