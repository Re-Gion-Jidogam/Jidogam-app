import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 하단 네비게이션 선택 탭 인덱스.
/// 0: 발견, 1: 지도, 2: 도장, 3: 프로필
final navIndexProvider = StateProvider<int>((ref) => 0);
