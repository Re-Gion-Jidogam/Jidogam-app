import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_assets.dart';
import '../models/place.dart';
import '../models/stamp.dart';

/// 지도 탭 더미 데이터 저장소. 추후 API로 교체.
class MapRepository {
  const MapRepository();

  /// "장소" 탭 기본(검색 전) 추천 리스트 — "여기는 어때요?".
  List<Place> recommendedPlaces() {
    const List<String> photos = <String>[
      AppImages.place1,
      AppImages.place2,
      AppImages.place3,
    ];
    return const <Place>[
      Place(
        id: 'a1a1c8b4-1111-4a11-8a11-000000000001',
        name: '투썸플레이스 안산그랑시티자이점',
        categoryCode: 'I56194',
        categoryName: '카페',
        jibunAddress: '경기도 안산시 상록구 사동 1301',
        roadAddress: '경기도 안산시 상록구 그랑로 44',
        latitude: 37.29892,
        longitude: 126.82914,
        distanceInKm: 0.158,
        exp: 15,
        photos: photos,
        guidebookCount: 4928,
      ),
      Place(
        id: 'a1a1c8b4-1111-4a11-8a11-000000000002',
        name: '스타벅스 안산중앙점',
        categoryCode: 'I56194',
        categoryName: '카페',
        jibunAddress: '경기도 안산시 단원구 고잔동 605',
        roadAddress: '경기도 안산시 단원구 중앙대로 923',
        latitude: 37.31871,
        longitude: 126.83752,
        distanceInKm: 0.42,
        exp: 10,
        photos: photos,
        guidebookCount: 2113,
      ),
      Place(
        id: 'a1a1c8b4-1111-4a11-8a11-000000000003',
        name: '전주 현대옥 본점',
        categoryCode: 'I56111',
        categoryName: '음식점',
        jibunAddress: '전북특별자치도 전주시 완산구 전동2가 1',
        roadAddress: '전북특별자치도 전주시 완산구 전동성당길 20',
        latitude: 35.81234,
        longitude: 127.14876,
        distanceInKm: 1.1,
        exp: 20,
        photos: photos,
        guidebookCount: 861,
      ),
      Place(
        id: 'a1a1c8b4-1111-4a11-8a11-000000000004',
        name: '망원한강공원',
        categoryCode: 'O91021',
        categoryName: '공원',
        jibunAddress: '서울특별시 마포구 망원동 466',
        roadAddress: '서울특별시 마포구 마포나루길 467',
        latitude: 37.55529,
        longitude: 126.89844,
        distanceInKm: 2.3,
        exp: 12,
        photos: photos,
        guidebookCount: 3450,
      ),
      Place(
        id: 'a1a1c8b4-1111-4a11-8a11-000000000005',
        name: '광안리해수욕장',
        categoryCode: 'O91031',
        categoryName: '관광명소',
        jibunAddress: '부산광역시 수영구 광안동 192',
        roadAddress: '부산광역시 수영구 광안해변로 219',
        latitude: 35.15325,
        longitude: 129.11871,
        distanceInKm: 15.6,
        exp: 25,
        photos: photos,
        guidebookCount: 5602,
      ),
      Place(
        id: 'a1a1c8b4-1111-4a11-8a11-000000000006',
        name: '을지로 커피한약방',
        categoryCode: 'I56194',
        categoryName: '카페',
        jibunAddress: '서울특별시 중구 을지로3가 6',
        roadAddress: '서울특별시 중구 수표로 45',
        latitude: 37.56636,
        longitude: 126.99138,
        distanceInKm: 0.05,
        exp: 8,
        photos: photos,
        guidebookCount: 1874,
      ),
      Place(
        id: 'a1a1c8b4-1111-4a11-8a11-000000000007',
        name: '경주 황리단길',
        categoryCode: 'O91031',
        categoryName: '관광명소',
        jibunAddress: '경상북도 경주시 황남동 145',
        roadAddress: '경상북도 경주시 포석로1080번길 5',
        latitude: 35.83694,
        longitude: 129.20977,
        distanceInKm: 8.9,
        exp: 18,
        photos: photos,
        guidebookCount: 3021,
      ),
      Place(
        id: 'a1a1c8b4-1111-4a11-8a11-000000000008',
        name: '속초 중앙시장',
        categoryCode: 'I56111',
        categoryName: '음식점',
        jibunAddress: '강원특별자치도 속초시 중앙동 471',
        roadAddress: '강원특별자치도 속초시 중앙시장로 45',
        latitude: 38.20517,
        longitude: 128.59267,
        distanceInKm: 3.4,
        exp: 14,
        photos: photos,
        guidebookCount: 2456,
      ),
      Place(
        id: 'a1a1c8b4-1111-4a11-8a11-000000000009',
        name: '여의도한강공원',
        categoryCode: 'O91021',
        categoryName: '공원',
        jibunAddress: '서울특별시 영등포구 여의동 84',
        roadAddress: '서울특별시 영등포구 여의동로 330',
        latitude: 37.52864,
        longitude: 126.93366,
        distanceInKm: 6.7,
        exp: 22,
        photos: photos,
        guidebookCount: 4102,
      ),
      Place(
        id: 'a1a1c8b4-1111-4a11-8a11-000000000010',
        name: '제주 협재해수욕장',
        categoryCode: 'O91031',
        categoryName: '관광명소',
        jibunAddress: '제주특별자치도 제주시 한림읍 협재리 2497',
        roadAddress: '제주특별자치도 제주시 한림읍 협재로 39',
        latitude: 33.39443,
        longitude: 126.2397,
        distanceInKm: 420.5,
        exp: 30,
        photos: photos,
        guidebookCount: 6789,
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
