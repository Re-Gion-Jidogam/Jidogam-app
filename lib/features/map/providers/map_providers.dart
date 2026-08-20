import 'package:flutter_riverpod/flutter_riverpod.dart';

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
