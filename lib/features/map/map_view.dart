import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/constants/app_assets.dart';

/// 지도 뷰 — 카카오맵 SDK 통합 지점.
///
/// 현재는 키가 없어 **정적 지도 플레이스홀더**(Figma 내보낸 지도 이미지)를
/// 렌더한다. 실제 카카오맵을 켜려면:
///   1. `pubspec.yaml`에 `kakao_map_plugin` 추가 후 `flutter pub get`.
///   2. Android `AndroidManifest.xml` / iOS `AppDelegate`에 네이티브 앱키 설정.
///   3. 앱 진입에서 `AuthRepository.initialize(appKey: AppConfig.kakaoMapKey)`.
///   4. 아래 `_buildKakaoMap`의 TODO를 `KakaoMap(...)` 위젯으로 교체.
/// 키는 `--dart-define=KAKAO_MAP_KEY=...`로 주입([AppConfig.kakaoMapKey]).
class KakaoMapView extends StatelessWidget {
  const KakaoMapView({super.key});

  @override
  Widget build(BuildContext context) {
    if (AppConfig.hasKakaoMapKey) {
      return _buildKakaoMap(context);
    }
    return const _MapPlaceholder();
  }

  Widget _buildKakaoMap(BuildContext context) {
    // TODO(kakao): 키 확보 시 kakao_map_plugin의 KakaoMap 위젯으로 교체.
    // return KakaoMap(onMapCreated: ...);
    return const _MapPlaceholder();
  }
}

/// 실제 지도 대신 보여주는 정적 한국 지도 이미지.
class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppImages.mapPlaceholder,
      fit: BoxFit.cover,
      alignment: const Alignment(0, -0.1),
    );
  }
}
