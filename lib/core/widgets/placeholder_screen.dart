import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_svg.dart';

/// 아직 구현되지 않은 탭을 위한 공통 플레이스홀더.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title, required this.icon});

  final String title;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AppSvg(icon, size: 36, color: AppColors.gray600),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.title18.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          Text('준비 중이에요', style: AppTextStyles.bannerSubtitle),
        ],
      ),
    );
  }
}
