import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/session.dart';

/// 인증 성공 공통 처리 — 세션 설정 + 시트 닫기 + 스낵바.
void completeAuth(
  BuildContext context,
  WidgetRef ref, {
  required String email,
  required String nickname,
  String message = '환영합니다!',
}) {
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  ref.read(sessionProvider.notifier).signIn(email: email, nickname: nickname);
  Navigator.of(context).pop();
  messenger.showSnackBar(
    SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
  );
}
