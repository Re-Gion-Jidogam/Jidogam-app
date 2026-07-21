import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/widgets/placeholder_screen.dart';

/// 프로필 탭 (플레이스홀더).
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: '프로필', icon: AppIcons.bnbProfile);
  }
}
