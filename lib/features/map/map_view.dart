import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

import '../../core/config/app_config.dart';
import '../../core/constants/app_assets.dart';
import 'data/location_service.dart';
import 'data/map_repository.dart';
import 'models/place.dart';

/// 지도 뷰 — 카카오맵 SDK 통합 지점.
///
/// 키([AppConfig.kakaoMapKey], `--dart-define=KAKAO_MAP_KEY=...`)가 있으면
/// 실제 카카오맵을 렌더하고, 없으면 **정적 지도 플레이스홀더**(Figma 내보낸
/// 지도 이미지)로 폴백한다. SDK 초기화는 앱 진입(`main.dart`)에서 한다.
class KakaoMapView extends ConsumerStatefulWidget {
  const KakaoMapView({super.key});

  @override
  ConsumerState<KakaoMapView> createState() => _KakaoMapViewState();
}

class _KakaoMapViewState extends ConsumerState<KakaoMapView> {
  /// onMapCreated로 받아 두는 컨트롤러 — 내 위치로 이동(setCenter)에 쓴다.
  KakaoMapController? _controller;

  /// 추천 장소가 비었을 때의 기본 중심 — 서울시청.
  static final LatLng _seoulCityHall = LatLng(37.5665, 126.9780);

  /// 장소 마커 + (있으면) 내 위치 핑.
  List<Marker> _markers(List<Place> places, LatLng? myLocation) => <Marker>[
        // 바텀시트의 "여기는 어때요?" 목록과 같은 장소들.
        for (final Place place in places)
          Marker(
            markerId: place.id,
            latLng: LatLng(place.latitude, place.longitude),
            infoWindowContent: place.name,
          ),
        // 현위치 버튼으로 찍은 내 위치.
        if (myLocation != null)
          Marker(
            markerId: 'my-location',
            latLng: myLocation,
            infoWindowContent: '내 위치',
          ),
      ];

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.hasKakaoMapKey) {
      return const _MapPlaceholder();
    }

    final List<Place> places = ref.watch(recommendedPlacesProvider);

    // 내 위치가 갱신되면(현위치 버튼 탭) 그 지점으로 지도를 옮기고 핑을 찍는다.
    ref.listen<LatLng?>(myLocationProvider, (LatLng? prev, LatLng? next) {
      if (next == null) return;
      _controller
        ?..setCenter(next)
        ..addMarker(markers: _markers(const <Place>[], next));
    });

    // 마커는 생성자에 넘기지 않는다 — 플러그인은 그걸 onPageFinished에 얹는데,
    // 그 시점엔 SDK의 kakao.maps.load()가 아직 안 끝나 map이 없어 실패한다.
    // 대신 지도가 확실히 준비된 onMapCreated에서, 그리고 탭 시점(위 listen)에서
    // 컨트롤러로 직접 얹는다.
    return KakaoMap(
      onMapCreated: (KakaoMapController controller) {
        _controller = controller;
        final List<Place> current = ref.read(recommendedPlacesProvider);
        final LatLng? loc = ref.read(myLocationProvider);
        controller.addMarker(markers: _markers(current, loc));
        // 지도 생성 전에 이미 내 위치가 정해졌다면 그 지점으로 옮긴다.
        if (loc != null) controller.setCenter(loc);
      },
      // 지도는 기본으로 첫 추천 장소에 맞춘다(현위치 버튼을 누르기 전 기준점).
      center: places.isEmpty
          ? _seoulCityHall
          : LatLng(places.first.latitude, places.first.longitude),
      currentLevel: 5,
    );
  }
}

/// 실제 지도 대신 보여주는 정적 한국 지도 이미지.
class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppImages.mapPlaceholder,
      fit: BoxFit.cover,
      alignment: const Alignment(0, -0.1),
    );
  }
}
