import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/chevron_right.dart';

/// 상단 프로모 배너 — "나만의 첫 가이드북 만들기" (로그아웃 상태).
class HomeHeaderBanner extends StatelessWidget {
  const HomeHeaderBanner({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 110,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: <Widget>[
            // 우측에 몰린 지도/나침반 일러스트 (좌측은 흰 여백).
            Positioned.fill(
              child: Image.asset(
                AppImages.bannerBg,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        '나만의 첫 가이드북 만들기',
                        style: AppTextStyles.title18,
                      ),
                      const SizedBox(width: 4),
                      const ChevronRight(length: 11, color: AppColors.gray900),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('로그인해서 시작하기', style: AppTextStyles.bannerSubtitle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
