/// 내가 찍은 도장(장소) 모델.
class Stamp {
  const Stamp({
    required this.placeName,
    required this.category,
    required this.rating,
    required this.address,
    required this.stampedDate,
  });

  final String placeName;
  final String category;
  final double rating;
  final String address;

  /// 표시용 도장 찍은 날짜 (예: `2025. 5. 14`).
  final String stampedDate;
}
