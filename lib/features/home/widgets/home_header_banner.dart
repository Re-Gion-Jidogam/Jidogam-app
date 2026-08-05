import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/chevron_right.dart';
import '../../auth/application/session.dart';
import '../../auth/presentation/auth_sheet.dart';

/// 상단 프로모 배너. 비로그인 시 인증 시트를 여는 CTA,
/// 로그인 시 환영 문구를 보여준다.
class HomeHeaderBanner extends ConsumerWidget {
  const HomeHeaderBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSession? session = ref.watch(sessionProvider);
    final bool loggedIn = session != null;

    final String title =
        loggedIn ? '${session.nickname}님, 환영해요' : '나만의 첫 가이드북 만들기';
    final String subtitle = loggedIn ? '즐거운 여행 되세요' : '로그인해서 시작하기';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: loggedIn ? null : () => showAuthSheet(context, ref),
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
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.title18,
                        ),
                      ),
                      if (!loggedIn) ...<Widget>[
                        const SizedBox(width: 4),
                        const ChevronRight(
                            length: 11, color: AppColors.gray900),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.bannerSubtitle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
