import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/home_repository.dart';
import 'models/guidebook.dart';
import 'models/place.dart';
import 'widgets/guidebook_card.dart';
import 'widgets/home_header_banner.dart';
import 'widgets/place_card.dart';
import 'widgets/section_title.dart';

/// 발견(홈) 화면 — 배너 + 가이드북/장소 섹션들의 세로 스크롤.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  /// 하단 플로팅 BNB 높이만큼 확보하는 스크롤 여백.
  static const double _bottomInset = 128;

  /// 섹션 간 간격.
  static const double _sectionGap = 48;

  /// 좌우 기본 여백.
  static const double _hPadding = 12;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Guidebook> waiting = ref.watch(waitingForYouProvider);
    final List<Guidebook> popular = ref.watch(popularGuidebooksProvider);
    final List<Place> places = ref.watch(popularPlacesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 12, bottom: _bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: _hPadding),
            child: HomeHeaderBanner(),
          ),
          const SizedBox(height: _sectionGap),
          _GuidebookSection(title: '당신을 기다리는 곳', guidebooks: waiting),
          const SizedBox(height: _sectionGap),
          _GuidebookSection(title: '인기 가이드북', guidebooks: popular),
          const SizedBox(height: _sectionGap),
          _PlaceSection(title: '인기 장소', places: places),
        ],
      ),
    );
  }
}

/// 가로 스크롤 가이드북 카드 섹션.
class _GuidebookSection extends StatelessWidget {
  const _GuidebookSection({required this.title, required this.guidebooks});

  final String title;
  final List<Guidebook> guidebooks;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: title,
      children: <Widget>[
        for (final Guidebook g in guidebooks) GuidebookCard(g),
      ],
    );
  }
}

/// 가로 스크롤 장소 카드 섹션.
class _PlaceSection extends StatelessWidget {
  const _PlaceSection({required this.title, required this.places});

  final String title;
  final List<Place> places;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: title,
      children: <Widget>[
        for (final Place p in places) PlaceCard(p),
      ],
    );
  }
}

/// 섹션 타이틀 + 가로 스크롤 카드 스트립.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: SectionTitle(title),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (int i = 0; i < children.length; i++) ...<Widget>[
                if (i > 0) const SizedBox(width: 12),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}
