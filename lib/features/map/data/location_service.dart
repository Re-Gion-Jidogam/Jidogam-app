import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

/// 현위치 버튼으로 찍은 내 위치(핑) 좌표 — null이면 아직 안 찍음.
final myLocationProvider = StateProvider<LatLng?>((ref) => null);

/// 위치 권한을 확보하고 현재 좌표를 가져온다.
///
/// 성공하면 [latLng]에 좌표를, 실패하면 [error]에 사용자 안내 문구를 담아
/// 반환한다(둘 중 하나만 채워진다).
Future<({LatLng? latLng, String? error})> resolveCurrentLocation() async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    return (latLng: null, error: '위치 서비스가 꺼져 있어요');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied) {
    return (latLng: null, error: '위치 권한이 필요해요');
  }
  if (permission == LocationPermission.deniedForever) {
    return (latLng: null, error: '설정에서 위치 권한을 허용해 주세요');
  }

  try {
    final Position position = await Geolocator.getCurrentPosition();
    return (latLng: LatLng(position.latitude, position.longitude), error: null);
  } catch (_) {
    return (latLng: null, error: '위치를 가져오지 못했어요');
  }
}
