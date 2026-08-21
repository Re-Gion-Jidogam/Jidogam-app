import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/map_repository.dart';
import '../models/place.dart';

/// 지도 상단 세그먼트 탭.
enum MapSegment {
  myStamp('내 도장'),
  place('장소'),
  guidebook('가이드북');

  const MapSegment(this.label);
  final String label;
}

/// 현재 선택된 세그먼트.
final mapSegmentProvider =
    StateProvider<MapSegment>((ref) => MapSegment.myStamp);

/// "장소" 탭에서 상세로 펼친 장소들 — 카드마다 독립적으로 펼쳐지고
/// 접혀서, 다른 카드를 선택해도 이미 펼친 카드는 그대로 유지된다.
final selectedPlacesProvider = StateProvider<Set<Place>>((ref) => <Place>{});

/// 이번 세션에서 도장찍기/도장 지우기로 바뀐 방문일 오버라이드.
/// key는 [Place.id], value는 새 [Place.visitedDate](도장찍기) 또는
/// null(도장 지우기) — 레포지토리의 정적 더미 데이터를 덮어써서 액션 직후
/// 카드가 바로 갱신되게 한다. 실 API 연동 시 이 provider는 통째로 걷어내면 된다.
final placeStampOverridesProvider =
    StateProvider<Map<String, DateTime?>>((ref) => <String, DateTime?>{});

/// [recommendedPlacesProvider] 위에 [placeStampOverridesProvider]를 얹은
/// 실사용 리스트 — 화면(장소 탭)은 항상 이 provider를 본다.
final effectivePlacesProvider = Provider<List<Place>>((ref) {
  final List<Place> places = ref.watch(recommendedPlacesProvider);
  final Map<String, DateTime?> overrides =
      ref.watch(placeStampOverridesProvider);
  if (overrides.isEmpty) return places;
  return <Place>[
    for (final Place place in places)
      overrides.containsKey(place.id)
          ? place.withVisitedDate(overrides[place.id])
          : place,
  ];
});
