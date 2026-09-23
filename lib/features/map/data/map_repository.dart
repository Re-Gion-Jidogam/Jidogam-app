import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_assets.dart';
import '../../home/models/guidebook.dart';
import '../../home/models/guidebook_review.dart';
import '../models/place.dart';
import '../models/stamp.dart';

/// 더미 가이드북들이 공유하는 소개글 — home_repository.dart의 것과 같은
/// 문구를 쓴다(다른 필드들처럼 더미 데이터를 파일 간에 그대로 재사용하는
/// 기존 컨벤션과 동일).
const String _burgerGuideDescription =
    '전주의 다양한 수제버거 맛집을 소개합니다. 직접 반죽한 빵과 신선한 재료로 '
    '만든 개성 있는 버거들을, 골목골목 숨은 맛집까지 모아 담았습니다...';

/// 상세 화면 리뷰 더미 — 모든 더미 가이드북이 공유한다.
const List<GuidebookReview> _burgerGuideReviews = <GuidebookReview>[
  GuidebookReview(
    rating: 2.8,
    timeAgo: '8시간 전',
    authorName: '지나가던 사람',
    authorLevel: 1384,
    content: '너무 맛있고 성능이 훌륭합니다. 스트레스 해소가 잘 되네요.',
  ),
  GuidebookReview(
    rating: 4.2,
    timeAgo: '1일 전',
    authorName: '햄버거 마니아',
    authorLevel: 872,
    content: '리스트 따라 다녀봤는데 숨은 맛집이 진짜 많아요. 강추합니다.',
  ),
  GuidebookReview(
    rating: 3.5,
    timeAgo: '3일 전',
    authorName: '전주 토박이',
    authorLevel: 214,
    content: '동네 사람만 아는 곳까지 들어있어서 놀랐어요.',
  ),
];

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

  /// "가이드북" 탭 "도전중인 가이드북" — 내가 참여 중인, 즉 아직 완료 전인
  /// 가이드북들이라 전부 별점 배지 대신 진행률 배지를 보여준다.
  /// 장소 수·진행률은 [guidebookDetailPlaces]에 맞춘다(10곳 중 2곳 방문).
  List<Guidebook> challengingGuidebooks() {
    final List<Place> places = guidebookDetailPlaces();
    return <Guidebook>[
      Guidebook(
        title: '햄버거에 미친 사람이 만든 전주 수제버거 맛집들',
        level: 3132,
        authorName: '지나가던 사람',
        rating: 2.8,
        placeCount: 10,
        publishedDate: '2025. 07. 05',
        rewardPoint: 59390,
        background:
            const EmojiBackground(color: Color(0xFFFFFF99), emoji: '🤔'),
        progress: const GuidebookProgress(completed: 2, total: 10),
        reviewCount: 881,
        reviews: _burgerGuideReviews,
        places: places,
      ),
      Guidebook(
        title: '햄버거에 미친 사람이 만든 전주 수제버거 맛집들',
        level: 3132,
        authorName: '지나가던 사람',
        rating: 2.8,
        placeCount: 10,
        publishedDate: '2025. 07. 05',
        rewardPoint: 59390,
        background: const ImageBackground(AppImages.guidebook1),
        progress: const GuidebookProgress(completed: 2, total: 10),
        reviewCount: 881,
        reviews: _burgerGuideReviews,
        places: places,
      ),
      Guidebook(
        title: '햄버거에 미친 사람이 만든 전주 수제버거 맛집들',
        level: 3132,
        authorName: '지나가던 사람',
        rating: 2.8,
        placeCount: 10,
        publishedDate: '2025. 07. 05',
        rewardPoint: 59390,
        background: const ImageBackground(AppImages.guidebook2),
        progress: const GuidebookProgress(completed: 2, total: 10),
        reviewCount: 881,
        reviews: _burgerGuideReviews,
        places: places,
      ),
      Guidebook(
        title: '햄버거에 미친 사람이 만든 전주 수제버거 맛집들',
        level: 3132,
        authorName: '지나가던 사람',
        rating: 2.8,
        placeCount: 10,
        publishedDate: '2025. 07. 05',
        rewardPoint: 59390,
        background:
            const EmojiBackground(color: Color(0xFF99B9FF), emoji: '🎉'),
        progress: const GuidebookProgress(completed: 2, total: 10),
        reviewCount: 881,
        reviews: _burgerGuideReviews,
        places: places,
      ),
    ];
  }

  /// 상세 화면 장소 더미 — 추천 리스트 재사용, 앞 2곳은 방문완료.
  /// 홈 레포지토리도 같은 목록을 쓴다.
  List<Place> guidebookDetailPlaces() {
    return recommendedPlaces()
        .asMap()
        .entries
        .map((MapEntry<int, Place> e) => e.key < 2
            ? e.value.withVisitedDate(DateTime(2025, 5, 14))
            : e.value)
        .toList();
  }

  /// 가이드북 브라우징 화면(`GuidebookBrowsePage`)의 일반 목록 — "이 장소가
  /// 포함된 가이드북"과 "가이드북 검색" 두 진입점이 함께 쓰는 더미 데이터.
  /// 두 진입점 모두 "특정 카테고리"가 아니라 "어떤 가이드북이든" 보여주는
  /// 자리라 같은 목록을 공유해도 자연스럽다.
  List<Guidebook> browsableGuidebooks() {
    final List<Place> places = guidebookDetailPlaces();
    return <Guidebook>[
      Guidebook(
        title: '햄버거에 미친 사람이 만든 전주 수제버거 맛집들',
        level: 3132,
        authorName: '지나가던 사람',
        rating: 2.8,
        placeCount: 10,
        publishedDate: '2025. 07. 05',
        rewardPoint: 59390,
        background: const ImageBackground(AppImages.guidebook1),
        description: _burgerGuideDescription,
        reviewCount: 881,
        reviews: _burgerGuideReviews,
        places: places,
      ),
      Guidebook(
        title: '햄버거에 미친 사람이 만든 전주 수제버거 맛집들',
        level: 3132,
        authorName: '지나가던 사람',
        rating: 2.8,
        placeCount: 10,
        publishedDate: '2025. 07. 05',
        rewardPoint: 59390,
        background:
            const EmojiBackground(color: Color(0xFFFFFF99), emoji: '🤔'),
        description: _burgerGuideDescription,
        // 도전 중 상태 시연용.
        progress: const GuidebookProgress(completed: 2, total: 10),
        reviewCount: 881,
        reviews: _burgerGuideReviews,
        places: places,
      ),
      Guidebook(
        title: '햄버거에 미친 사람이 만든 전주 수제버거 맛집들',
        level: 3132,
        authorName: '지나가던 사람',
        rating: 2.8,
        placeCount: 10,
        publishedDate: '2025. 07. 05',
        rewardPoint: 59390,
        background: const ImageBackground(AppImages.guidebook2),
        description: _burgerGuideDescription,
        reviewCount: 881,
        reviews: _burgerGuideReviews,
        places: places,
      ),
      Guidebook(
        title: '햄버거에 미친 사람이 만든 전주 수제버거 맛집들',
        level: 3132,
        authorName: '지나가던 사람',
        rating: 2.8,
        placeCount: 10,
        publishedDate: '2025. 07. 05',
        rewardPoint: 59390,
        background:
            const EmojiBackground(color: Color(0xFF99B9FF), emoji: '🎉'),
        description: _burgerGuideDescription,
        reviewCount: 881,
        reviews: _burgerGuideReviews,
        places: places,
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

/// 더미(레포지토리 원본) "도전중인 가이드북" 목록. 카드 속 "지나가던 사람"은
/// 실제로는 로그인한 유저 자신이라, 화면은 이 provider가 아니라 세션
/// 닉네임을 덮어쓴 [challengingGuidebooksProvider](map_providers.dart)를 본다.
final rawChallengingGuidebooksProvider = Provider<List<Guidebook>>(
  (ref) => ref.watch(mapRepositoryProvider).challengingGuidebooks(),
);

final browsableGuidebooksProvider = Provider<List<Guidebook>>(
  (ref) => ref.watch(mapRepositoryProvider).browsableGuidebooks(),
);
