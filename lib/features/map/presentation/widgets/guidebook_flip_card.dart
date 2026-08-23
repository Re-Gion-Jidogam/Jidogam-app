import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/chevron_right.dart';
import '../../../home/models/guidebook.dart';
import '../../../home/widgets/guidebook_card.dart';

/// 가이드북 브라우징 화면(`GuidebookBrowsePage`)에서 카드 한 장씩 넘겨보는
/// 카드 — [GuidebookCard]와 똑같은 앞면으로 시작해서, 잠시 멈춰 있으면
/// (또는 직접 탭하면) 자동으로 뒤집혀 소개글 있는 뒷면([_GuidebookCardBack],
/// 지도 배경)을 보여준다. 다음 카드로 넘기면(=이 위젯이 다시 만들어지면)
/// 항상 앞면부터 다시 시작한다.
class GuidebookFlipCard extends StatefulWidget {
  const GuidebookFlipCard(this.guidebook, {super.key});

  final Guidebook guidebook;

  static const double width = 300;
  static const double height = 400;

  @override
  State<GuidebookFlipCard> createState() => _GuidebookFlipCardState();
}

class _GuidebookFlipCardState extends State<GuidebookFlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _autoFlipTimer;
  bool _showingBack = false;

  static const Duration _flipDuration = Duration(milliseconds: 500);

  /// "옆으로 넘기다가 일정 시간 멈추면 뒤집혀서 뒷면(지도+소개글)이
  /// 나온다"는 원 의도대로, 카드가 뜨고 이만큼 조작이 없으면 자동으로
  /// 뒤집는다.
  static const Duration _autoFlipDelay = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _flipDuration);
    _scheduleAutoFlip();
  }

  @override
  void dispose() {
    _autoFlipTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _scheduleAutoFlip() {
    _autoFlipTimer?.cancel();
    _autoFlipTimer = Timer(_autoFlipDelay, () {
      if (mounted && !_showingBack) _flip();
    });
  }

  void _flip() {
    _autoFlipTimer?.cancel();
    setState(() => _showingBack = !_showingBack);
    if (_showingBack) {
      _controller.forward();
    } else {
      _controller.reverse();
      // 다시 앞면으로 돌아왔으면 자동 뒤집기 타이머를 재시작한다.
      _scheduleAutoFlip();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 자동 뒤집기를 기다리지 않고 손으로도 앞뒤를 오갈 수 있게 한다.
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          final double angle = _controller.value * math.pi;
          final bool showBackFace = angle > math.pi / 2;
          return Transform(
            alignment: Alignment.center,
            // 원근감 있는 3D 회전처럼 보이도록 살짝 perspective를 준다.
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateY(angle),
            child: showBackFace
                ? Transform(
                    alignment: Alignment.center,
                    // 뒷면 콘텐츠 자체가 거울상으로 보이지 않도록 180°
                    // 되돌려 그린다.
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _GuidebookCardBack(widget.guidebook),
                  )
                : GuidebookCard(
                    widget.guidebook,
                    width: GuidebookFlipCard.width,
                    height: GuidebookFlipCard.height,
                  ),
          );
        },
      ),
    );
  }
}

/// [GuidebookFlipCard]의 뒷면 — 지도(장소 도장 마커) 배경 위에 밝은
/// 그라데이션과 소개글을 얹는다(Figma `card-front-detail`).
class _GuidebookCardBack extends StatelessWidget {
  const _GuidebookCardBack(this.guidebook);

  final Guidebook guidebook;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: GuidebookFlipCard.width,
      height: GuidebookFlipCard.height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(AppImages.guidebookBrowseMap, fit: BoxFit.cover),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: RatingBadge(guidebook.rating),
                ),
              ),
              const Spacer(),
              _BackDetail(guidebook),
            ],
          ),
        ],
      ),
    );
  }
}

class _BackDetail extends StatelessWidget {
  const _BackDetail(this.guidebook);

  final Guidebook guidebook;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 32, 18, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0x00FFFFFF), Color(0xCCFFFFFF)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  guidebook.title,
                  style: AppTextStyles.cardTitle18,
                ),
              ),
              const ChevronRight(length: 14),
            ],
          ),
          const SizedBox(height: 6),
          Opacity(opacity: 0.8, child: _MetaLines(guidebook)),
          const SizedBox(height: 8),
          Text(
            guidebook.description ?? _fallbackDescription,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.placeMeta
                .copyWith(fontSize: 12, height: 1.4, color: AppColors.sheetTitle),
          ),
        ],
      ),
    );
  }
}

/// [Guidebook.description]이 없는 더미 데이터(예: "도전중인 가이드북")를
/// 이 화면에서 보게 될 경우를 위한 대체 문구.
const String _fallbackDescription = '아직 소개글이 없는 가이드북이에요.';

class _MetaLines extends StatelessWidget {
  const _MetaLines(this.guidebook);

  final Guidebook guidebook;

  @override
  Widget build(BuildContext context) {
    final TextStyle medium =
        AppTextStyles.cardMetaMedium.copyWith(color: AppColors.textSecondary);
    final TextStyle bold =
        AppTextStyles.cardMetaBold.copyWith(color: AppColors.textSecondary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('Lv. ${guidebook.level} · ${guidebook.authorName}', style: medium),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: <InlineSpan>[
                    TextSpan(text: '총 ', style: medium),
                    TextSpan(text: '${guidebook.placeCount}개', style: bold),
                    TextSpan(text: '의 장소 · ', style: medium),
                    TextSpan(
                        text: '${guidebook.publishedDate}에 출판', style: medium),
                  ],
                ),
              ),
            ),
          ],
        ),
        Text.rich(
          TextSpan(
            children: <InlineSpan>[
              TextSpan(text: '가이드북 완료시 ', style: medium),
              TextSpan(
                text: '${_formatThousands(guidebook.rewardPoint)}p',
                style: bold,
              ),
            ],
          ),
        ),
      ],
    );
  }
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
