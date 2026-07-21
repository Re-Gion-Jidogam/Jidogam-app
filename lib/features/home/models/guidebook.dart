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
}
