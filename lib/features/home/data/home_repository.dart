import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_assets.dart';
import '../models/guidebook.dart';
import '../models/place.dart';

/// 홈(발견) 화면 더미 데이터 저장소.
///
/// 퍼블리싱 단계라 정적 데이터를 반환한다. 추후 API 연동 시 이 클래스만
/// 교체하면 UI 계층은 그대로 유지된다.
class HomeRepository {
  const HomeRepository();

  /// "당신을 기다리는 곳" — 이모지 패턴형 가이드북.
  List<Guidebook> waitingForYou() {
    return const <Guidebook>[
      Guidebook(
        title: '햄버거에 미친 사람이 만든 전주 수제버거 맛집들',
        level: 3132,
        authorName: '지나가던 사람',
        rating: 2.8,
        placeCount: 483,
        publishedDate: '2025. 07. 05',
        rewardPoint: 59390,
        background: EmojiBackground(color: Color(0xFFFFFF99), emoji: '🤔'),
      ),
      Guidebook(
        title: '햄버거에 미친 사람이 만든 전주 수제버거 맛집들',
        level: 3132,
        authorName: '지나가던 사람',
        rating: 2.8,
        placeCount: 483,
        publishedDate: '2025. 07. 05',
        rewardPoint: 59390,
        background: EmojiBackground(color: Color(0xFF99B9FF), emoji: '🎉'),
      ),
    ];
  }

  /// "인기 가이드북" — 사진형 가이드북.
  List<Guidebook> popularGuidebooks() {
    return const <Guidebook>[
      Guidebook(
        title: '햄버거에 미친 사람이 만든 전주 수제버거 맛집들',
        level: 3132,
        authorName: '지나가던 사람',
        rating: 2.8,
        placeCount: 483,
        publishedDate: '2025. 07. 05',
        rewardPoint: 59390,
        background: ImageBackground(AppImages.guidebook1),
      ),
      Guidebook(
        title: '햄버거에 미친 사람이 만든 전주 수제버거 맛집들',
        level: 3132,
        authorName: '지나가던 사람',
        rating: 2.8,
        placeCount: 483,
        publishedDate: '2025. 07. 05',
        rewardPoint: 59390,
        background: ImageBackground(AppImages.guidebook2),
      ),
    ];
  }

  /// "인기 장소" — 장소 카드.
  List<Place> popularPlaces() {
    const List<String> photos = <String>[
      AppImages.place1,
      AppImages.place2,
      AppImages.place3,
    ];
    return const <Place>[
      Place(
        name: '투썸플레이스 안산그랑시티자이점',
        category: '카페',
        rating: 2.8,
        address: '경기 안산시 상록구 사동',
        photos: photos,
      ),
      Place(
        name: '투썸플레이스 안산그랑시티자이점',
        category: '카페',
        rating: 2.8,
        address: '경기 안산시 상록구 사동',
        photos: photos,
      ),
    ];
  }
}

// ── Riverpod providers ──────────────────────────────────────────

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => const HomeRepository(),
);

final waitingForYouProvider = Provider<List<Guidebook>>(
  (ref) => ref.watch(homeRepositoryProvider).waitingForYou(),
);

final popularGuidebooksProvider = Provider<List<Guidebook>>(
  (ref) => ref.watch(homeRepositoryProvider).popularGuidebooks(),
);

final popularPlacesProvider = Provider<List<Place>>(
  (ref) => ref.watch(homeRepositoryProvider).popularPlaces(),
);
