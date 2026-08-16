/// 지도 "장소" 탭 추천 리스트용 장소 모델.
class Place {
  const Place({
    required this.name,
    required this.category,
    required this.rating,
    required this.address,
  });

  final String name;
  final String category;
  final double rating;
  final String address;
}
