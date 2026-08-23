import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/session.dart';
import '../../home/models/guidebook.dart';
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

/// [rawChallengingGuidebooksProvider] 위에 로그인 세션 닉네임을 얹은
/// 실사용 리스트 — "도전중인 가이드북" 카드 속 "지나가던 사람"은 더미
/// 데이터의 고정 이름이 아니라 실제로는 로그인한 유저 자신이다. 이 목록
/// 자체가 로그인 상태에서만 화면에 노출되므로("도전중인 가이드북" 섹션은
/// 비로그인이면 아예 안 뜬다) 닉네임이 없을 일은 없지만, 방어적으로
/// 더미 이름을 그대로 둔다.
final challengingGuidebooksProvider = Provider<List<Guidebook>>((ref) {
  final String? nickname = ref.watch(sessionProvider)?.nickname;
  final List<Guidebook> guidebooks = ref.watch(rawChallengingGuidebooksProvider);
  if (nickname == null) return guidebooks;
  return <Guidebook>[
    for (final Guidebook guidebook in guidebooks)
      guidebook.withAuthorName(nickname),
  ];
});
