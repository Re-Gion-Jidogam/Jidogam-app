import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/shell/main_shell.dart';

/// 지도감 앱 루트.
class JidogamApp extends StatelessWidget {
  const JidogamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jidogam',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const MainShell(),
    );
  }
}
