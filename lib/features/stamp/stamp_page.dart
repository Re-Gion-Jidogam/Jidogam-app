import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/widgets/placeholder_screen.dart';

/// 도장 탭 (플레이스홀더).
class StampPage extends StatelessWidget {
  const StampPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: '도장', icon: AppIcons.bnbStamp);
  }
}
