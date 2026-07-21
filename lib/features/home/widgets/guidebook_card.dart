import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_svg.dart';
import '../../../core/widgets/chevron_right.dart';
import '../models/guidebook.dart';

/// 가이드북 대형 카드 (240×278).
///
/// 배경(이모지 패턴 / 사진) 위에 상단 평점 배지와 하단 그라데이션 정보
/// 오버레이를 얹는다.
class GuidebookCard extends StatelessWidget {
  const GuidebookCard(this.guidebook, {super.key, this.onTap});

  final Guidebook guidebook;
  final VoidCallback? onTap;

  static const double _width = 240;
  static const double _height = 278;
  static const double _radius = 20;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: _width,
        height: _height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(color: Colors.white),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            _Background(guidebook.background),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                  child: _RatingBadge(guidebook.rating),
                ),
                const Spacer(),
                _CardBackDetail(guidebook),
              ],
            ),
            Positioned(
              right: 14,
              bottom: 60,
              child: ChevronRight(length: 14, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

/// 카드 배경 — 이모지 패턴 또는 사진.
class _Background extends StatelessWidget {
  const _Background(this.background);

  final GuidebookBackground background;

  @override
  Widget build(BuildContext context) {
    return switch (background) {
      ImageBackground(:final assetPath) => Image.asset(
        assetPath,
        fit: BoxFit.cover,
      ),
      EmojiBackground(:final color, :final emoji) => _EmojiPattern(
        color: color,
        emoji: emoji,
      ),
    };
  }
}

/// 단색 위에 대형 이모지를 20° 기울여 반복 배치한 배경.
class _EmojiPattern extends StatelessWidget {
  const _EmojiPattern({required this.color, required this.emoji});

  final Color color;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    const int rows = 6;
    const int cols = 4;
    return Container(
      color: color,
      child: Center(
        child: OverflowBox(
          minWidth: 0,
          minHeight: 0,
          maxWidth: double.infinity,
          maxHeight: double.infinity,
          child: Transform.rotate(
            angle: 20 * 3.1415926535 / 180,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List<Widget>.generate(rows, (int r) {
                return Padding(
                  padding: EdgeInsets.only(
                    // 벽돌쌓기식 어긋남
                    left: r.isEven ? 34 : 0,
                    top: r == 0 ? 0 : 12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List<Widget>.generate(cols, (int c) {
                      return Padding(
                        padding: EdgeInsets.only(left: c == 0 ? 0 : 14),
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 68, height: 1),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

/// 상단 평점 배지 — 반투명 흰 pill.
class _RatingBadge extends StatelessWidget {
  const _RatingBadge(this.rating);

  final double rating;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xD9FFFFFF),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: const Color(0x66FFFFFF)),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x1A000000),
                offset: Offset(0, 4),
                blurRadius: 14,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AppSvg(AppIcons.star, size: 10, color: AppColors.gray900),
              const SizedBox(width: 2),
              Text(_formatRating(rating), style: AppTextStyles.ratingBadge),
            ],
          ),
        ),
      ),
    );
  }
}

/// 하단 그라데이션 정보 오버레이.
class _CardBackDetail extends StatelessWidget {
  const _CardBackDetail(this.guidebook);

  final Guidebook guidebook;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 32, 18, 18),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Color(0x00000000), Color(0x33000000)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                guidebook.title,
                style: AppTextStyles.cardTitle18.copyWith(
                  color: Colors.white,
                  shadows: const <Shadow>[
                    Shadow(color: Color(0x33000000), blurRadius: 10),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Opacity(
                opacity: 0.8,
                child: _MetaBlock(guidebook),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaBlock extends StatelessWidget {
  const _MetaBlock(this.guidebook);

  final Guidebook guidebook;

  @override
  Widget build(BuildContext context) {
    final TextStyle medium =
        AppTextStyles.cardMetaMedium.copyWith(color: Colors.white);
    final TextStyle bold =
        AppTextStyles.cardMetaBold.copyWith(color: Colors.white);
    final TextStyle regular =
        AppTextStyles.cardMetaRegular.copyWith(color: Colors.white);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('Lv. ${guidebook.level} · ${guidebook.authorName}', style: medium),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: AppSvg(AppIcons.star, size: 8, color: Colors.white),
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: <InlineSpan>[
                    TextSpan(text: _formatRating(guidebook.rating), style: regular),
                    TextSpan(text: ' · 총 ', style: medium),
                    TextSpan(text: '${guidebook.placeCount}개', style: bold),
                    TextSpan(text: '의 장소 · ', style: medium),
                    TextSpan(text: '${guidebook.publishedDate}에 출판', style: medium),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text.rich(
          TextSpan(
            children: <InlineSpan>[
              TextSpan(text: '가이드북 완료시 ', style: medium),
              TextSpan(text: '${_formatThousands(guidebook.rewardPoint)}p', style: bold),
            ],
          ),
        ),
      ],
    );
  }
}

String _formatRating(double rating) {
  return rating == rating.roundToDouble()
      ? rating.toStringAsFixed(1)
      : rating.toString();
}

String _formatThousands(int value) {
  final String digits = value.toString();
  final StringBuffer buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}
