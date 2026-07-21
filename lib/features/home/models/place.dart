/// 장소(placeCard) 모델.
class Place {
  const Place({
    required this.name,
    required this.category,
    required this.rating,
    required this.address,
    required this.photos,
  });

  final String name;
  final String category;
  final double rating;
  final String address;

  /// 장소 사진 에셋 경로 목록(카드에는 앞 3장 노출).
  final List<String> photos;
}
