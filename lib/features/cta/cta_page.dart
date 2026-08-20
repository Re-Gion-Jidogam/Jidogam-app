import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/travel_stamp_badge.dart';
import '../auth/presentation/auth_sheet.dart';

/// 비로그인 상태에서 로그인이 필요한 액션(예: 도장찍기)을 눌렀을 때 보여주는
/// 전면 CTA 화면 (Figma `/CTA`, node 289:7715).
class CtaPage extends ConsumerWidget {
  const CtaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      // 도장 패턴은 좌우 여백 없이 화면 끝까지 꽉 채워야 하므로(피그마 기준),
      // 가로 패딩은 하단 텍스트/버튼 블록에만 적용하고 Column 레벨에는 두지 않는다.
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 24),
            const Expanded(child: ClipRect(child: _FadedStampBackdrop())),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
              child: Column(
                children: <Widget>[
                  Text(
                    '여행 좋아하시나요?',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.ctaTitle24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '로그인해서 도장찍고 여행력을 모아보세요!',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.ctaSubtitle14,
                  ),
                  const SizedBox(height: 48),
                  PrimaryButton(
                    label: '시작하기',
                    onPressed: () => showAuthSheet(context, ref),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: 45,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text(
                        '괜찮아요',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// [_StampBackdrop]의 위/아래 가장자리를 투명하게 그라데이션 처리해
/// 텍스트·상단 상태바 영역으로 자연스럽게 스며들 듯 사라지게 한다.
class _FadedStampBackdrop extends StatelessWidget {
  const _FadedStampBackdrop();

  static const double _fadeStop = 0.14;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Colors.transparent,
            Colors.black,
            Colors.black,
            Colors.transparent,
          ],
          stops: <double>[0.0, _fadeStop, 1.0 - _fadeStop, 1.0],
        ).createShader(bounds);
      },
      child: const _StampBackdrop(),
    );
  }
}

/// 회전된 TRAVEL 도장 타일이 격자로 깔리는 장식 배경.
///
/// 화면 크기와 무관하게 회전 후에도 네 모서리까지 빈틈없이 덮도록, 가용 영역의
/// 대각선 길이를 기준으로 타일 격자 크기를 동적으로 계산한다.
class _StampBackdrop extends StatelessWidget {
  const _StampBackdrop();

  static const double _tileWidth = 183;
  static const double _spacing = 24;
  static const double _angle = -19.39 * math.pi / 180;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double diagonal = math.sqrt(
          constraints.maxWidth * constraints.maxWidth +
              constraints.maxHeight * constraints.maxHeight,
        );
        // 회전으로 잘려나가는 모서리까지 커버할 여유분(1.3배)을 둔다.
        final double side = diagonal * 1.3;
        final int perSide = (side / (_tileWidth + _spacing)).ceil() + 1;

        return OverflowBox(
          maxWidth: side,
          maxHeight: side,
          child: Transform.rotate(
            angle: _angle,
            child: Wrap(
              spacing: _spacing,
              runSpacing: _spacing,
              children: List<Widget>.generate(
                perSide * perSide,
                (int i) => const TravelStampBadge(width: _tileWidth),
              ),
            ),
          ),
        );
      },
    );
  }
}
