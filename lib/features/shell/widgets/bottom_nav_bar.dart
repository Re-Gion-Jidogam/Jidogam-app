import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_svg.dart';
import '../providers/nav_provider.dart';

/// 하단 네비게이션 탭 정의.
class _NavItem {
  const _NavItem({required this.icon, required this.label});
  final String icon;
  final String label;
}

const List<_NavItem> _items = <_NavItem>[
  _NavItem(icon: AppIcons.bnbDiscover, label: '발견'),
  _NavItem(icon: AppIcons.bnbMap, label: '지도'),
  _NavItem(icon: AppIcons.bnbStamp, label: '도장'),
  _NavItem(icon: AppIcons.bnbProfile, label: '프로필'),
];

/// 하단 플로팅 pill 형태의 커스텀 네비게이션 바.
class BottomNavBar extends ConsumerWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int selected = ref.watch(navIndexProvider);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(100),
            boxShadow: AppColors.commonShadow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              for (int i = 0; i < _items.length; i++)
                _NavButton(
                  item: _items[i],
                  selected: i == selected,
                  onTap: () =>
                      ref.read(navIndexProvider.notifier).state = i,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color =
        selected ? AppColors.navActive : AppColors.navInactive;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: 24,
            child: Center(
              child: AppSvg(item.icon, size: 20, color: color),
            ),
          ),
          const SizedBox(height: 2),
          Text(item.label, style: AppTextStyles.navLabel.copyWith(color: color)),
        ],
      ),
    );
  }
}
