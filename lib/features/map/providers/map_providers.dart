import 'package:flutter_riverpod/flutter_riverpod.dart';

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
