/// 지도 "장소" 탭 추천/검색 리스트용 장소 모델.
///
/// 서버 응답 필드를 그대로 따른다(예: `pid`→[id], `y`/`x`→위경도). [rating]과
/// [photos]는 서버 응답에 없는 프론트 전용 필드다 — [rating]은 리뷰 API
/// 연동 전까지 null(카드엔 '별점없음' 표시), [photos]는 상세 카드용 더미 사진.
class Place {
  const Place({
    required this.id,
    required this.name,
    required this.categoryCode,
    required this.categoryName,
    required this.jibunAddress,
    required this.roadAddress,
    required this.latitude,
    required this.longitude,
    required this.distanceInKm,
    required this.exp,
    this.visitedDate,
    this.guidebookCount = 0,
    this.stampCount = 0,
    this.rating,
    this.photos = const <String>[],
  });

  /// 서버 응답의 `pid`.
  final String id;

  final String name;

  /// 서버 응답의 `categoryCode`(예: `G20603`).
  final String categoryCode;

  /// 서버 응답의 `categoryName`(예: '생수/음료 소매업').
  final String categoryName;

  /// 서버 응답의 `jibunAddress`.
  final String jibunAddress;

  /// 서버 응답의 `roadAddress` — 카드엔 이 주소를 노출한다.
  final String roadAddress;

  /// 서버 응답의 `y`(위도).
  final double latitude;

  /// 서버 응답의 `x`(경도).
  final double longitude;

  /// 현재 위치 기준 거리(km) — 서버가 계산해서 내려준다.
  final double distanceInKm;

  /// 이 장소에서 도장찍기로 얻는 경험치.
  final int exp;

  /// 마지막 방문(도장) 일시 — 방문한 적 없으면 null.
  final DateTime? visitedDate;

  /// 이 장소가 포함된 가이드북 개수(상세 카드에 노출).
  final int guidebookCount;

  /// 이 장소에 도장을 찍은 횟수.
  final int stampCount;

  /// 평점 — 서버 응답엔 없는 필드. 리뷰 API 연동 전까지 null(카드엔 '별점없음' 표시).
  final double? rating;

  /// 상세 카드용 장소 사진 에셋 경로 목록(앞 3장 노출) — 서버 응답에 없는 프론트 전용 목 데이터.
  final List<String> photos;
}
