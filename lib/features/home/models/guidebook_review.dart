/// 가이드북 상세 화면의 리뷰 카드 하나(Figma `reviewCard`).
class GuidebookReview {
  const GuidebookReview({
    required this.rating,
    required this.timeAgo,
    required this.authorName,
    required this.authorLevel,
    required this.content,
  });

  final double rating;

  /// 상대 작성 시점(예: "8시간 전").
  final String timeAgo;

  final String authorName;
  final int authorLevel;
  final String content;
}
