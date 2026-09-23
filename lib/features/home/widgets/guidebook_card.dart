import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_svg.dart';
import '../../../core/widgets/chevron_right.dart';
import '../models/guidebook.dart';

/// 가이드북 대형 카드. 기본 240×278(홈 "당신을 기다리는 곳"/"인기 가이드북"
/// 가로 스크롤 카드) — [width]/[height]를 주면 지도 "가이드북" 탭의
/// 전체너비 196px 카드처럼 다른 크기로도 쓸 수 있다.
///
/// 배경(이모지 패턴 / 사진) 위에 상단 배지(평점, 또는 [Guidebook.progress]가
/// 있으면 진행률)와 하단 그라데이션 정보 오버레이를 얹는다.
class GuidebookCard extends StatelessWidget {
  const GuidebookCard(
    this.guidebook, {
    super.key,
    this.onTap,
    this.onDetailTap,
    this.width = 240,
    this.height = 278,
  });

  final Guidebook guidebook;
  final VoidCallback? onTap;

  /// 하단 텍스트 영역 탭. null이면 [onTap]을 쓴다.
  final VoidCallback? onDetailTap;
  final double width;
  final double height;

  static const double _radius = 20;

  @override
  Widget build(BuildContext context) {
    final GuidebookProgress? progress = guidebook.progress;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
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
                  child: progress == null
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: RatingBadge(guidebook.rating),
                        )
                      : ProgressBadge(progress),
                ),
                const Spacer(),
                _CardBackDetail(guidebook, onTap: onDetailTap),
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

/// 상단 평점 배지 — 반투명 흰 pill. [GuidebookCard]와 가이드북 브라우징
/// 화면(`GuidebookBrowsePage`)의 카드 뒷면이 함께 쓰는 공용 위젯이라 공개해뒀다.
class RatingBadge extends StatelessWidget {
  const RatingBadge(this.rating, {super.key});

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

/// 진행률 배지(Figma `card-star` progress 변형) — 도전 중 카드에서
/// [RatingBadge] 대신 뜬다. 가이드북 상세 화면도 함께 쓴다.
class ProgressBadge extends StatelessWidget {
  const ProgressBadge(
    this.progress, {
    super.key,
    this.outerShadow,
    this.trackColor = const Color(0x66FFFFFF),
  });

  final GuidebookProgress progress;

  /// 배지 바깥에만 그리는 그림자(반투명 트랙 안쪽엔 비치지 않게).
  final List<BoxShadow>? outerShadow;

  /// 안 채워진 트랙 색. 밝은 배경 위에선 흰 채움과 구분되게 회색을 준다.
  final Color trackColor;

  static const double _height = 26;

  @override
  Widget build(BuildContext context) {
    final double fraction = progress.total == 0
        ? 0
        : (progress.completed / progress.total).clamp(0.0, 1.0);
    final Widget badge = ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
        child: Container(
          height: _height,
          decoration: BoxDecoration(
            color: trackColor,
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
          child: Stack(
            // 기본 정렬(topStart)이면 텍스트 Row가 자기 높이만큼만 차지해
            // 26px 트랙 위쪽에 붙는다 — 세로로 가운데 오도록 center로 맞춘다.
            alignment: Alignment.center,
            children: <Widget>[
              // 진행률만큼만 채워지는 흰 배경 — 트랙 전체 너비에 비례.
              Positioned.fill(
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: fraction,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: AppColors.commonShadow,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      '${progress.percent}% 완료',
                      style: AppTextStyles.ratingBadge,
                    ),
                    Text(
                      '${_formatThousands(progress.completed)} / ${_formatThousands(progress.total)}',
                      style: AppTextStyles.cardMetaRegular
                          .copyWith(color: AppColors.gray900, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (outerShadow == null) return badge;
    return CustomPaint(
      painter: _OuterShadowPainter(outerShadow!),
      child: badge,
    );
  }
}

/// 알약 모양 바깥에만 그림자를 그린다.
class _OuterShadowPainter extends CustomPainter {
  const _OuterShadowPainter(this.shadows);

  final List<BoxShadow> shadows;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final RRect shape =
        RRect.fromRectAndRadius(rect, Radius.circular(size.height / 2));
    // 알약 안쪽을 오려낸 영역으로 클립.
    final Path outside = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(rect.inflate(100))
      ..addRRect(shape);
    canvas.save();
    canvas.clipPath(outside);
    for (final BoxShadow shadow in shadows) {
      canvas.drawRRect(
        shape.shift(shadow.offset).inflate(shadow.spreadRadius),
        shadow.toPaint(),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_OuterShadowPainter oldDelegate) =>
      oldDelegate.shadows != shadows;
}

/// 하단 그라데이션 정보 오버레이.
class _CardBackDetail extends StatelessWidget {
  const _CardBackDetail(this.guidebook, {this.onTap});

  final Guidebook guidebook;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ClipRect(
        child: BackdropFilter(
          // Figma `card-back-detail` 스펙 — backdrop-filter: blur(50px).
          filter: ui.ImageFilter.blur(sigmaX: 50, sigmaY: 50),
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
