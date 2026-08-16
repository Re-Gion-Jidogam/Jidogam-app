import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/circle_back_button.dart';
import '../../../core/widgets/resizable_bottom_sheet.dart';
import '../../shell/providers/nav_provider.dart';
import '../data/map_repository.dart';
import '../map_view.dart';
import '../models/place.dart';
import '../models/stamp.dart';
import '../providers/map_providers.dart';
import 'widgets/current_location_button.dart';
import 'widgets/map_search_field.dart';
import 'widgets/map_segmented_control.dart';
import 'widgets/place_list_card.dart';
import 'widgets/stamp_card.dart';

/// 지도 탭 — 지도 + 상단 세그먼트 + 리사이즈 바텀시트(내 도장).
class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  /// 현재 시트 높이 비율(0~1) — dimmer/현위치 버튼 위치 구동.
  final ValueNotifier<double> _extent = ValueNotifier<double>(0.45);

  @override
  void dispose() {
    _sheetController.dispose();
    _extent.dispose();
    super.dispose();
  }

  String _searchHint(MapSegment segment) => switch (segment) {
        MapSegment.myStamp => '내가 찍은 도장 검색하기',
        MapSegment.place => '어디로 가볼까요?',
        MapSegment.guidebook => '내 가이드북 검색',
      };

  @override
  Widget build(BuildContext context) {
    final MapSegment segment = ref.watch(mapSegmentProvider);
    final List<Stamp> stamps = ref.watch(myStampsProvider);
    final List<Place> places = ref.watch(recommendedPlacesProvider);
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          // 지도(플레이스홀더).
          const Positioned.fill(child: KakaoMapView()),

          // full 근접 시 페이드인되는 dimmer.
          Positioned.fill(
            child: ValueListenableBuilder<double>(
              valueListenable: _extent,
              builder: (BuildContext context, double extent, _) {
                final double t =
                    ((extent - 0.7) / (0.95 - 0.7)).clamp(0.0, 1.0);
                return IgnorePointer(
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: 0.2 * t),
                  ),
                );
              },
            ),
          ),

          // 상단: 뒤로가기 + 세그먼트.
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: <Widget>[
                  CircleBackButton(
                    onTap: () =>
                        ref.read(navIndexProvider.notifier).state = 0,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(child: MapSegmentedControl()),
                ],
              ),
            ),
          ),

          // 현위치 버튼 — 시트 위에 붙어 이동.
          ValueListenableBuilder<double>(
            valueListenable: _extent,
            builder: (BuildContext context, double extent, _) {
              return Positioned(
                right: 16,
                bottom: extent * screenHeight + 16,
                child: CurrentLocationButton(onTap: () {}),
              );
            },
          ),

          // 리사이즈 바텀시트.
          NotificationListener<DraggableScrollableNotification>(
            onNotification: (DraggableScrollableNotification n) {
              _extent.value = n.extent;
              return false;
            },
            child: ResizableBottomSheet(
              controller: _sheetController,
              contentBuilder: (BuildContext context,
                      ScrollController scrollController) =>
                  _SheetContent(
                scrollController: scrollController,
                segment: segment,
                stamps: stamps,
                places: places,
                searchHint: _searchHint(segment),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 세그먼트별 시트 콘텐츠.
class _SheetContent extends StatelessWidget {
  const _SheetContent({
    required this.scrollController,
    required this.segment,
    required this.stamps,
    required this.places,
    required this.searchHint,
  });

  final ScrollController scrollController;
  final MapSegment segment;
  final List<Stamp> stamps;
  final List<Place> places;
  final String searchHint;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      children: <Widget>[
        MapSearchField(hint: searchHint),
        const SizedBox(height: 24),
        switch (segment) {
          MapSegment.myStamp => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _myStamp(),
            ),
          MapSegment.place => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _place(),
            ),
          MapSegment.guidebook => _comingSoon(segment),
        },
      ],
    );
  }

  List<Widget> _myStamp() {
    return <Widget>[
      Text('내가 찍은 도장', style: AppTextStyles.title18),
      const SizedBox(height: 12),
      for (int i = 0; i < stamps.length; i++) ...<Widget>[
        if (i > 0) const SizedBox(height: 12),
        StampCard(stamps[i]),
      ],
    ];
  }

  List<Widget> _place() {
    return <Widget>[
      Text('여기는 어때요?', style: AppTextStyles.title18),
      const SizedBox(height: 12),
      for (int i = 0; i < places.length; i++) ...<Widget>[
        if (i > 0) const SizedBox(height: 12),
        PlaceListCard(places[i]),
      ],
    ];
  }

  Widget _comingSoon(MapSegment segment) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Center(
        child: Text(
          '${segment.label} 준비 중이에요',
          style: AppTextStyles.title18.copyWith(color: AppColors.textMuted),
        ),
      ),
    );
  }
}
