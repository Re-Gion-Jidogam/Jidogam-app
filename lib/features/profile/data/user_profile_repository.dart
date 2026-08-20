import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 도장찍기 쿨다운 — 마지막으로 찍은 뒤 이 시간 안에는 다시 못 찍는다.
const Duration stampCooldownDuration = Duration(minutes: 5);

/// 유저 프로필 조회 API 목(mock) 저장소. 추후 실제 API로 교체.
///
/// [lastStampedAt]은 장소 API 응답이 아니라 이 유저 프로필 API에서 내려오는
/// 값이다 — 특정 장소가 아니라 유저 전역 기준 "마지막으로 도장 찍은 시각"이라,
/// 도장찍기 쿨다운(연속 찍기 방지)을 이 값 하나로 판단한다.
class UserProfileRepository {
  const UserProfileRepository();

  /// 마지막으로 도장을 찍은 시각. null이면 아직 한 번도 찍지 않은 상태.
  DateTime? lastStampedAt() => null;
}

final userProfileRepositoryProvider = Provider<UserProfileRepository>(
  (ref) => const UserProfileRepository(),
);

final lastStampedAtProvider = Provider<DateTime?>(
  (ref) => ref.watch(userProfileRepositoryProvider).lastStampedAt(),
);

/// 쿨다운 잔여 시간(분, 올림) — 아직 쿨다운 중이 아니면(한 번도 안 찍었거나
/// [stampCooldownDuration]이 지났으면) null. 장소 카드의 "도장찍기" 버튼과
/// "장소" 탭 검색결과 헤더의 안내 문구가 이 값을 함께 쓴다.
int? stampCooldownRemainingMinutes(DateTime? lastStampedAt) {
  if (lastStampedAt == null) return null;
  final Duration remaining =
      stampCooldownDuration - DateTime.now().difference(lastStampedAt);
  if (remaining <= Duration.zero) return null;
  return (remaining.inSeconds / 60).ceil();
}
