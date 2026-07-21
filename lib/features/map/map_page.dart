import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/widgets/placeholder_screen.dart';

/// 지도 탭 (플레이스홀더).
class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: '지도', icon: AppIcons.bnbMap);
  }
}
