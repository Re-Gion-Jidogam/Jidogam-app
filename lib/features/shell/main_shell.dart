import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../home/home_page.dart';
import '../map/presentation/map_page.dart';
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

    // 지도 탭(1)은 전체화면 지도라 BNB를 숨긴다(디자인: 뒤로가기 버튼으로 복귀).
    final bool showNavBar = index != 1;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: IndexedStack(index: index, children: _pages),
            ),
          ),
          if (showNavBar)
            const Align(
              alignment: Alignment.bottomCenter,
              child: BottomNavBar(),
            ),
        ],
      ),
    );
  }
}
