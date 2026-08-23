import 'package:flutter/painting.dart';

/// 가이드북 카드 배경. 이모지 패턴형 또는 사진형 두 가지.
sealed class GuidebookBackground {
  const GuidebookBackground();
}

/// 단색 배경 위에 대형 이모지가 반복되는 배경.
class EmojiBackground extends GuidebookBackground {
  const EmojiBackground({required this.color, required this.emoji});

  final Color color;
  final String emoji;
}

/// 사진 한 장을 꽉 채우는 배경.
class ImageBackground extends GuidebookBackground {
  const ImageBackground(this.assetPath);

  final String assetPath;
}

/// 도전 중인 가이드북의 완료율 — 있으면 [GuidebookCard] 상단이 별점 배지
/// 대신 진행률 배지("N% 완료" + "완료수/전체수")를 보여준다.
class GuidebookProgress {
  const GuidebookProgress({required this.completed, required this.total});

  final int completed;
  final int total;

  int get percent => total == 0 ? 0 : (completed / total * 100).round();
}

/// 가이드북(큰 카드) 모델.
class Guidebook {
  const Guidebook({
    required this.title,
    required this.level,
    required this.authorName,
    required this.rating,
    required this.placeCount,
    required this.publishedDate,
    required this.rewardPoint,
    required this.background,
    this.progress,
  });

  final String title;
  final int level;
  final String authorName;
  final double rating;
  final int placeCount;

  /// 표시용 출판일 문자열 (예: `2025. 07. 05`).
  final String publishedDate;

  /// 완료 시 지급 포인트.
  final int rewardPoint;

  final GuidebookBackground background;

  /// 도전 중인 가이드북의 진행률(map `/map/guidebook`의 "도전중인 가이드북"
  /// 리스트에서 씀) — null이면 [GuidebookCard] 상단에 평소처럼 별점 배지가 뜬다.
  final GuidebookProgress? progress;

  /// [authorName]만 바꾼 사본. "도전중인 가이드북"처럼 카드 속 인물이 실은
  /// 로그인한 유저 자신인 목록에서, 더미 데이터의 고정 이름 대신 세션
  /// 닉네임을 끼워 넣을 때 쓴다.
  Guidebook withAuthorName(String authorName) => Guidebook(
        title: title,
        level: level,
        authorName: authorName,
        rating: rating,
        placeCount: placeCount,
        publishedDate: publishedDate,
        rewardPoint: rewardPoint,
        background: background,
        progress: progress,
      );
}
