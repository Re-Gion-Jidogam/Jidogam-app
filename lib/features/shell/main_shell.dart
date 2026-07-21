import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../home/home_page.dart';
import '../map/map_page.dart';
import '../profile/profile_page.dart';
import '../stamp/stamp_page.dart';
import 'providers/nav_provider.dart';
import 'widgets/bottom_nav_bar.dart';

/// 4개 탭을 담는 최상위 셸. 하단 플로팅 BNB로 탭을 전환하며,
/// [IndexedStack]으로 각 탭의 상태를 유지한다.
class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    MapPage(),
    StampPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int index = ref.watch(navIndexProvider);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: IndexedStack(index: index, children: _pages),
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: BottomNavBar(),
          ),
        ],
      ),
    );
  }
}
