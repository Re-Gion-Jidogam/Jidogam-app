# 지도 탭 + 리사이즈 바텀시트 컨벤션 — 설계 (UI 퍼블리싱)

- 날짜: 2026-08-05
- 범위(이번 세션): 재사용 **리사이즈 바텀시트 셸** + 지도 탭 **골격**(카카오맵 스캐폴드·세그먼트·검색·현위치) + **내 도장** 탭 콘텐츠. 장소/가이드북 탭 콘텐츠, 지도 마커(키 필요)는 후속.
- 지도 SDK: **카카오맵**, **키 없이 스캐폴딩**(SDK 통합 지점 + 정적 지도 플레이스홀더, 키는 config/env).
- Figma: full 상태 `372:12180`, 컨벤션 셸 `256:4060`, my-stamp 상태들(peek/half/auto).

## 리사이즈 컨벤션 (4상태)
| 상태 | 높이 | 내용 |
|---|---|---|
| 01 검색창만 | peek (핸들+검색바) | 검색바만 노출 |
| 02 half | 45vh | 검색바 + 리스트 |
| 03 auto | 콘텐츠 맞춤 | 선택 장소 카드 (후속) |
| 04 full | 95vh + dimmer | 검색 + 카드 풀리스트 |

## 컴포넌트
- `core/widgets/resizable_bottom_sheet.dart` — `DraggableScrollableSheet` 기반. 스냅 peek/half(0.45)/full(0.95), 드래그 + Riverpod 제어. grabber·상단 라운드20·blur20 translucent 크롬(기존 시트 룩 공유). **full 근접 시 dimmer 페이드인**(`DraggableScrollableNotification` extent 구독).
- `features/map/`
  - `presentation/map_page.dart` — 카카오맵(스캐폴드+플레이스홀더) + 상단 세그먼트 pill + 뒤로가기 + 현위치 버튼 + 리사이즈 시트.
  - `presentation/widgets/map_segmented_control.dart` — 내 도장/장소/가이드북 3분할 pill(선택=흰 배경).
  - `presentation/widgets/map_search_field.dart` — 라운드100 검색바(아이콘+placeholder).
  - `presentation/widgets/current_location_button.dart` — 흰 원형 + 위치 아이콘.
  - `presentation/widgets/stamp_card.dart` — 내 도장 카드(이름·카테고리·평점·주소·도장찍음일 + TRAVEL 워터마크).
  - `data/map_repository.dart` — 더미 도장 데이터 + Riverpod provider.
  - `providers/map_providers.dart` — 세그먼트 탭 상태.
  - `map_view.dart` (KakaoMapView) — 키 있으면 카카오맵, 없으면 정적 지도 이미지 플레이스홀더. 실제 SDK 활성화 지점(주석/문서).

## 카카오맵 스캐폴딩
- `AppConfig.kakaoMapKey`(= `String.fromEnvironment('KAKAO_MAP_KEY')`) 비어있으면 플레이스홀더.
- 실제 활성화: `kakao_map_plugin` 추가 + 네이티브 키 설정 + `KakaoMapView`에서 `KakaoMap` 인스턴스화. (키 확보 시 국소 작업.)
- 플레이스홀더 지도 = Figma 지도 이미지(`assets/images/map_placeholder.png`).

## 상태관리
- 세그먼트 탭(내 도장/장소/가이드북) StateProvider. 시트 스냅은 `DraggableScrollableController`.
- 더미 도장 데이터(투썸플레이스 …).

## 새 토큰/에셋
- 색: 기존 토큰으로 충분(gray800/gray200 등). 검색 placeholder `#808080`은 gray600 근사 또는 신규.
- 에셋: 검색 아이콘 SVG, 지도 플레이스홀더 PNG.

## 검증
- 시뮬레이터: 드래그 리사이즈(peek↔half↔full) + dimmer 페이드 + 세그먼트 전환 + 검색바 + 내 도장 리스트 (플레이스홀더 지도 위). `flutter analyze`/`test` 통과.
