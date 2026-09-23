import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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
/// 그라데이션과 소개글을 얹는다(Figma `card-front-detail`). 앞면(제목·별점·
/// Lv/작성자·장소수·출판일·리워드)과 겹치는 정보는 다시 보여주지 않고,
/// 앞면에 없는 소개글만 담는다.
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
          Align(
            alignment: Alignment.bottomCenter,
            child: _BackDetail(guidebook),
          ),
        ],
      ),
    );
  }
}

class _BackDetail extends StatelessWidget {
  const _BackDetail(this.guidebook);

  final Guidebook guidebook;

  // Figma `card-front-detail`(91:5237) 스펙: backdrop-blur 20px 고정.
  // (위쪽만 슬라이스로 서서히 강하게 해봤다가 경계에 단차가 보여서 되돌림)
  static const double _blur = 20;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: _blur, sigmaY: _blur),
        child: Container(
          width: double.infinity,
          // Figma는 고정 높이 200이지만 우리 더미 소개글(3줄)엔 부족해
          // 넘친다 — 높이는 내용에 맞춰 늘리고, 그라데이션 스펙만 따른다.
          padding: const EdgeInsets.fromLTRB(18, 32, 18, 18),
          decoration: const BoxDecoration(
            // Figma 그라데이션(0%/28%/80% 불투명도)보다 아래쪽이 더 진하게
            // 보이도록 70%/85%로 올렸다.
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Color(0x00FFFFFF), Color(0xB3FFFFFF), Color(0xD9FFFFFF)],
              stops: <double>[0.0, 0.28, 1.0],
            ),
          ),
          child: Text(
            guidebook.description ?? _fallbackDescription,
            // 카드는 고정 높이(400)라 너무 긴 소개글은 잘라준다.
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.placeMeta
                .copyWith(fontSize: 12, height: 1.4, color: AppColors.sheetTitle),
          ),
        ),
      ),
    );
  }
}

/// [Guidebook.description]이 없는 더미 데이터(예: "도전중인 가이드북")를
/// 이 화면에서 보게 될 경우를 위한 대체 문구.
const String _fallbackDescription = '아직 소개글이 없는 가이드북이에요.';
