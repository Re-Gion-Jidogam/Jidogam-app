import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'features/auth/application/session.dart';

/// 개발용 목 계정 자동 로그인. 끄려면 `--dart-define=DEV_AUTO_LOGIN=false`.
const bool kDevAutoLogin =
    bool.fromEnvironment('DEV_AUTO_LOGIN', defaultValue: true);

void main() {
  runApp(
    ProviderScope(
      overrides: <Override>[
        if (kDevAutoLogin)
          sessionProvider.overrideWith(_DevSignedInSessionController.new),
      ],
      child: const JidogamApp(),
    ),
  );
}

/// 목 계정으로 로그인된 채 시작하는 세션 컨트롤러(개발용).
class _DevSignedInSessionController extends SessionController {
  @override
  AppSession? build() =>
      const AppSession(email: 'test@example.com', nickname: '지나가던 사람');
}
