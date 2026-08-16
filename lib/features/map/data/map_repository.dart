import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/place.dart';
import '../models/stamp.dart';

/// 지도 탭 더미 데이터 저장소. 추후 API로 교체.
class MapRepository {
  const MapRepository();

  /// "장소" 탭 기본(검색 전) 추천 리스트 — "여기는 어때요?".
  List<Place> recommendedPlaces() {
    return const <Place>[
      Place(
        name: '투썸플레이스 안산그랑시티자이점',
        category: '카페',
        rating: 2.8,
        address: '경기 안산시 상록구 사동',
      ),
      Place(
        name: '스타벅스 안산중앙점',
        category: '카페',
        rating: 4.2,
        address: '경기 안산시 단원구 고잔동',
      ),
      Place(
        name: '전주 현대옥 본점',
        category: '음식점',
        rating: 4.6,
        address: '전북 전주시 완산구 전동',
      ),
      Place(
        name: '망원한강공원',
        category: '공원',
        rating: 4.8,
        address: '서울 마포구 망원동',
      ),
      Place(
        name: '광안리해수욕장',
        category: '관광명소',
        rating: 4.5,
        address: '부산 수영구 광안동',
      ),
    ];
  }

  List<Stamp> myStamps() {
    return const <Stamp>[
      Stamp(
        placeName: '투썸플레이스 안산그랑시티자이점',
        category: '카페',
        rating: 2.8,
        address: '경기 안산시 상록구 사동',
        stampedDate: '2025. 5. 14',
      ),
      Stamp(
        placeName: '스타벅스 안산중앙점',
        category: '카페',
        rating: 4.2,
        address: '경기 안산시 단원구 고잔동',
        stampedDate: '2025. 5. 2',
      ),
      Stamp(
        placeName: '전주 현대옥 본점',
        category: '음식점',
        rating: 4.6,
        address: '전북 전주시 완산구 전동',
        stampedDate: '2025. 4. 21',
      ),
      Stamp(
        placeName: '망원한강공원',
        category: '공원',
        rating: 4.8,
        address: '서울 마포구 망원동',
        stampedDate: '2025. 4. 3',
      ),
    ];
  }
}

final mapRepositoryProvider = Provider<MapRepository>(
  (ref) => const MapRepository(),
);

final myStampsProvider = Provider<List<Stamp>>(
  (ref) => ref.watch(mapRepositoryProvider).myStamps(),
);

final recommendedPlacesProvider = Provider<List<Place>>(
  (ref) => ref.watch(mapRepositoryProvider).recommendedPlaces(),
);
