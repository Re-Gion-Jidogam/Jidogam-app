import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../home/models/guidebook.dart';
import '../map_view.dart';
import 'widgets/guidebook_flip_card.dart';
import 'widgets/map_search_field.dart';

/// 가이드북을 한 장씩 넘겨보는 화면(Figma `/map/guidebook/list/search`).
///
/// 진입 경로 4개(장소 상세 "이 장소가 포함된 가이드북", "인기 가이드북",
/// "OOO님을 기다리는 곳", 가이드북 검색)가 전부 이 화면 하나를 같이 쓰고
/// [title]/[guidebooks]/[resultCountLabel]/[searchHint]만 달라진다.
///
/// 스크롤 리스트가 아니라 [PageView] 캐러셀이다 — 카드 하나가 화면 가운데
/// 뜨고, 화살표(또는 스와이프)로 옆 카드로 넘긴다. 각 카드는
/// [GuidebookFlipCard]라 잠시 멈춰 있으면 저절로 뒤집혀 소개글을 보여준다.
class GuidebookBrowsePage extends StatefulWidget {
  const GuidebookBrowsePage({
    super.key,
    required this.title,
    required this.guidebooks,
    required this.resultCountLabel,
    this.searchHint,
  });

  final String title;
  final List<Guidebook> guidebooks;

  /// 하단 안내 문구(예: "1,392개의 가이드북을 찾았어요") — 실제 [guidebooks]
  /// 길이와는 무관한 더미 통계 문구다(장소 카드의 "가이드북 4,928개"처럼
  /// 이 앱의 다른 더미 카운트들과 같은 컨벤션).
  final String resultCountLabel;

  /// null이 아니면 하단에 닫기(X) 달린 검색바가 뜬다("가이드북 검색" 진입).
  final String? searchHint;

  @override
  State<GuidebookBrowsePage> createState() => _GuidebookBrowsePageState();
}

class _GuidebookBrowsePageState extends State<GuidebookBrowsePage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int delta) {
    final int next =
        (_currentIndex + delta).clamp(0, widget.guidebooks.length - 1);
    if (next == _currentIndex) return;
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final List<Guidebook> guidebooks = widget.guidebooks;
    final bool isEmpty = guidebooks.isEmpty;
    final Guidebook? current = isEmpty ? null : guidebooks[_currentIndex];

    return Scaffold(
      body: Stack(
        children: <Widget>[
          const Positioned.fill(child: KakaoMapView()),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: screenHeight * 0.95,
            child: AppBottomSheet(
              title: widget.title,
              onBack: () => Navigator.of(context).pop(),
              child: current == null
                  ? const _EmptyState()
                  : Column(
                      children: <Widget>[
                        _CaptionRow(
                          guidebook: current,
                          hasPrev: _currentIndex > 0,
                          hasNext: _currentIndex < guidebooks.length - 1,
                          onPrev: () => _goTo(-1),
                          onNext: () => _goTo(1),
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: guidebooks.length,
                            onPageChanged: (int i) =>
                                setState(() => _currentIndex = i),
                            itemBuilder: (BuildContext context, int i) => Center(
                              child: GuidebookFlipCard(
                                guidebooks[i],
                                key: ValueKey<int>(i),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.resultCountLabel,
                          style: AppTextStyles.helper
                              .copyWith(color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 12),
                        if (widget.searchHint != null)
                          MapSearchField(
                            hint: widget.searchHint!,
                            onClose: () => Navigator.of(context).pop(),
                          ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 좌우 화살표 + 현재 카드의 타이틀/작성자/장소 수(Figma 캡션 블록).
class _CaptionRow extends StatelessWidget {
  const _CaptionRow({
    required this.guidebook,
    required this.hasPrev,
    required this.hasNext,
    required this.onPrev,
    required this.onNext,
  });

  final Guidebook guidebook;
  final bool hasPrev;
  final bool hasNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _ArrowButton(icon: Icons.chevron_left, enabled: hasPrev, onTap: onPrev),
        const SizedBox(width: 28),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                guidebook.title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.title18.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 8),
              Text(
                'Lv. ${guidebook.level} · ${guidebook.authorName}',
                textAlign: TextAlign.center,
                style:
                    AppTextStyles.placeMeta.copyWith(color: AppColors.textMuted),
              ),
              Text(
                '총 ${guidebook.placeCount}개의 장소',
                textAlign: TextAlign.center,
                style:
                    AppTextStyles.placeMeta.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 28),
        _ArrowButton(icon: Icons.chevron_right, enabled: hasNext, onTap: onNext),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: SizedBox(
        width: 28,
        height: 28,
        child: Icon(
          icon,
          size: 28,
          color: enabled ? AppColors.textPrimary : AppColors.gray300,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '아직 가이드북이 없어요',
        style: AppTextStyles.title18.copyWith(color: AppColors.textMuted),
      ),
    );
  }
}
