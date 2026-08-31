import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/circle_back_button.dart';
import '../../../core/widgets/resizable_bottom_sheet.dart';
import '../../../core/widgets/success_toast.dart';
import '../../profile/data/user_profile_repository.dart';
import '../../shell/providers/nav_provider.dart';
import '../data/location_service.dart';
import '../data/map_repository.dart';
import '../map_view.dart';
import '../models/place.dart';
import '../models/stamp.dart';
import '../providers/map_providers.dart';
import 'widgets/current_location_button.dart';
import 'widgets/map_search_field.dart';
import 'widgets/map_segmented_control.dart';
import 'widgets/place_detail_card.dart';
import 'widgets/place_list_card.dart';
import 'widgets/stamp_card.dart';
import 'widgets/stamp_dialogs.dart';

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

  /// 카드 하나를 펼치거나 접는다 — 다른 카드가 펼쳐져 있어도 건드리지 않는다.
  void _togglePlace(Place place) {
    final StateController<Set<Place>> notifier =
        ref.read(selectedPlacesProvider.notifier);
    final Set<Place> current = notifier.state;
    notifier.state = current.contains(place)
        ? (<Place>{...current}..remove(place))
        : <Place>{...current, place};
  }

  /// "도장찍기" 확인 → 확정 시 방문일 기록 + 쿨다운 갱신 + 성공 토스트.
  Future<void> _handleStamp(Place place) async {
    final bool confirmed =
        await showStampConfirmDialog(context, placeName: place.name);
    if (!confirmed) return;

    final DateTime now = DateTime.now();
    ref.read(placeStampOverridesProvider.notifier).update(
          (Map<String, DateTime?> overrides) =>
              <String, DateTime?>{...overrides, place.id: now},
        );
    ref.read(lastStampedAtProvider.notifier).state = now;

    if (!mounted) return;
    showSuccessToast(context, emphasis: place.name, suffix: '에 도장을 찍었어요');
  }

  /// "도장 지우기" 확인 → 확정 시 방문일 제거 + 성공 토스트.
  Future<void> _handleRemoveStamp(Place place) async {
    final bool confirmed =
        await showStampRemoveDialog(context, placeName: place.name);
    if (!confirmed) return;

    ref.read(placeStampOverridesProvider.notifier).update(
          (Map<String, DateTime?> overrides) =>
              <String, DateTime?>{...overrides, place.id: null},
        );

    if (!mounted) return;
    showSuccessToast(context, emphasis: place.name, suffix: ' 도장을 지웠어요');
  }

  /// 현위치 버튼 → 위치 권한 확보 후 내 위치로 지도 이동 + 핑 찍기.
  /// 권한/서비스가 막히면 안내 스낵바를 띄운다.
  Future<void> _handleMyLocation() async {
    final result = await resolveCurrentLocation();
    if (!mounted) return;
    if (result.latLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error ?? '위치를 가져올 수 없어요')),
      );
      return;
    }
    ref.read(myLocationProvider.notifier).state = result.latLng;
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
    final List<Place> places = ref.watch(effectivePlacesProvider);
    final Set<Place> selectedPlaces = ref.watch(selectedPlacesProvider);
    final int? cooldownRemainingMinutes =
        stampCooldownRemainingMinutes(ref.watch(lastStampedAtProvider));
    final double screenHeight = MediaQuery.of(context).size.height;
    // 시트가 최대로 올라와도 상단 세그먼트/뒤로가기를 가리지 않도록,
    // 안전영역 + 상단 컨트롤(패딩 8 + 높이 34) + 여백 16만큼을 비워 둔다.
    final double topReserved = MediaQuery.of(context).padding.top + 8 + 34 + 16;
    final double sheetMaxSize = 1 - topReserved / screenHeight;

    // 다른 세그먼트로 넘어가면 상세 선택을 초기화한다.
    ref.listen<MapSegment>(mapSegmentProvider, (MapSegment? prev, MapSegment next) {
      if (next != MapSegment.place &&
          ref.read(selectedPlacesProvider).isNotEmpty) {
        ref.read(selectedPlacesProvider.notifier).state = <Place>{};
      }
    });

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
                // 시트 최대치 근처(위 0.18 구간)에서 dimmer가 서서히 짙어진다.
                final double t =
                    ((extent - (sheetMaxSize - 0.18)) / 0.18).clamp(0.0, 1.0);
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
                child: CurrentLocationButton(onTap: _handleMyLocation),
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
              maxChildSize: sheetMaxSize,
              contentBuilder: (BuildContext context,
                      ScrollController scrollController) =>
                  _SheetContent(
                scrollController: scrollController,
                segment: segment,
                stamps: stamps,
                places: places,
                searchHint: _searchHint(segment),
                selectedPlaces: selectedPlaces,
                cooldownRemainingMinutes: cooldownRemainingMinutes,
                onTogglePlace: _togglePlace,
                onStamp: _handleStamp,
                onRemoveStamp: _handleRemoveStamp,
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
    required this.selectedPlaces,
    required this.cooldownRemainingMinutes,
    required this.onTogglePlace,
    required this.onStamp,
    required this.onRemoveStamp,
  });

  final ScrollController scrollController;
  final MapSegment segment;
  final List<Stamp> stamps;
  final List<Place> places;
  final String searchHint;
  final Set<Place> selectedPlaces;

  /// 도장찍기 쿨다운 잔여 시간(분) — 쿨다운 중이 아니면 null.
  /// "장소" 탭 헤더 바로 아래 안내 문구를 띄우는 데 쓴다.
  final int? cooldownRemainingMinutes;
  final ValueChanged<Place> onTogglePlace;
  final ValueChanged<Place> onStamp;
  final ValueChanged<Place> onRemoveStamp;

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
      // Figma(`Frame 2610735`)에서 헤더는 카드 로우 기준 x=8에서 시작한다
      // (카드 안쪽 텍스트의 x=18과는 다른 값 — 서로 맞출 필요 없음).
      Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('여기는 어때요?', style: AppTextStyles.title18),
            // 최근(쿨다운 이내)에 도장을 찍었으면, 목록 전체가 아직 못 찍는
            // 상태임을 헤더 바로 아래에서 미리 알려준다(Figma `/map/place`
            // 검색결과 헤더 문구와 동일한 스타일).
            if (cooldownRemainingMinutes != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                '$cooldownRemainingMinutes분 뒤에 도장을 찍을 수 있어요',
                style:
                    AppTextStyles.helper.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 12),
      for (int i = 0; i < places.length; i++) ...<Widget>[
        if (i > 0) const SizedBox(height: 12),
        // 다른 페이지로 이동하지 않고, 탭한 카드가 그 자리에서 커지며 상세를
        // 보여준다 — 나머지 카드는 그대로 리스트에 남는다(다른 카드를 펼쳐도
        // 이미 펼친 카드가 자동으로 접히지 않는다).
        // AnimatedCrossFade는 두 자식을 선택 상태와 무관하게 항상 같이
        // 빌드해두고 Offstage로만 감추므로("다른 카드는 목록으로만 남는다"는
        // 전제와 어긋남), 선택된 쪽 위젯 하나만 실제로 빌드되도록
        // AnimatedSize(크기)+AnimatedSwitcher(페이드)를 같은 지속시간·커브로
        // 맞춰서 쓴다. 접힐 때 굼떠 보이지 않도록 짧게 잡는다.
        AnimatedSize(
          key: ValueKey<String>('card-${places[i].name}'),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            transitionBuilder: (Widget child, Animation<double> animation) =>
                FadeTransition(opacity: animation, child: child),
            // 기본 layoutBuilder는 사라지는 카드도 포지션 없이 그대로 쌓아서,
            // 그 카드가 더 크면(상세→목록으로 접힐 때) Stack이 사라질 때까지
            // 큰 크기를 유지하다 마지막 순간에 확 줄어든다 — 이게 바깥
            // AnimatedSize와 타이밍이 어긋나 깜빡이듯 보이는 원인이다. 사라지는
            // 카드를 Positioned.fill로 흐름에서 빼서 크기가 항상 "다음에 보여줄
            // 카드" 기준으로만 잡히게 한다.
            layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
              return Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  // top/left/right만 고정하고 bottom은 비워, 사라지는 카드가
                  // Stack 높이에 맞춰 억지로 눌리지 않고 원래 높이 그대로
                  // 자연스럽게 겹쳐 있다가 페이드아웃되게 한다.
                  for (final Widget child in previousChildren)
                    Positioned(top: 0, left: 0, right: 0, child: child),
                  ?currentChild,
                ],
              );
            },
            child: selectedPlaces.contains(places[i])
                ? PlaceDetailCard(
                    places[i],
                    key: ValueKey<String>('detail-${places[i].name}'),
                    onCollapse: () => onTogglePlace(places[i]),
                    // 가이드북 추가는 아직 실제 동작이 없지만, 다른
                    // 미구현 버튼들(예: CurrentLocationButton)과 같은
                    // 컨벤션으로 퍼블리싱 단계에선 눌리는 것처럼 보이게
                    // 빈 콜백을 둔다.
                    onGuidebookTap: () {},
                    onAddToGuidebook: () {},
                    onStamp: () => onStamp(places[i]),
                    onRemoveStamp: () => onRemoveStamp(places[i]),
                  )
                : PlaceListCard(
                    places[i],
                    key: ValueKey<String>('list-${places[i].name}'),
                    onTap: () => onTogglePlace(places[i]),
                  ),
          ),
        ),
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
