# CLAUDE.md

지도감(Jidogam) — 장소를 모아 가이드북을 만드는 Flutter 모바일 앱. 이 문서는 이 레포에서 작업하는 Claude/에이전트를 위한 지침이다.

## 명령어

```bash
flutter pub get        # 의존성 설치
flutter run            # 실행 (기기/시뮬레이터 지정: -d <id>)
flutter analyze        # 정적 분석 — 커밋 전 반드시 통과(0 issues)
flutter test           # 위젯/단위 테스트
```

디자인 대조가 필요하면 iPhone SE(3rd gen, 375pt)가 디자인 폭과 일치한다:
`xcrun simctl boot <udid> && flutter run -d <udid>` 후 `xcrun simctl io <udid> screenshot out.png`.

## 아키텍처

- **상태관리**: Riverpod(`flutter_riverpod`). 진입점 `main.dart`는 `ProviderScope`로 감싼다.
- **폴더 구조**: feature-first.
  - `lib/core/` — 앱 전역 공통. `theme/`(색·타이포·테마 토큰), `constants/app_assets.dart`(에셋 경로), `widgets/`(공통 위젯: `AppSvg`, `ChevronRight`, `PlaceholderScreen`).
  - `lib/features/<feature>/` — 기능별. `models/`, `data/`(레포지토리 + Riverpod provider), `widgets/`, `<feature>_page.dart`.
  - `lib/features/shell/` — 하단 4탭을 담는 `MainShell`(IndexedStack) + 플로팅 pill `BottomNavBar`. 탭 인덱스는 `nav_provider.dart`.
- **네비게이션**: 현재 `IndexedStack` + Riverpod `StateProvider`(탭 상태 유지). 별도 라우팅 패키지 없음.
- **데이터**: 퍼블리싱 단계라 `*Repository`가 정적 더미 데이터를 반환한다. API 연동 시 레포지토리만 교체하고 UI/provider는 유지한다.

## 디자인 시스템 (단일 출처)

- 색: `lib/core/theme/app_colors.dart` — Figma 변수(`gray/*`, `primary/*`) 원시 팔레트 + 시맨틱 별칭. **하드코딩 색상 금지**, 반드시 토큰 사용.
- 타이포: `lib/core/theme/app_text_styles.dart` — 폰트는 **Pretendard**(assets/fonts, weight 400/500/600/700).
- 아이콘: Figma에서 내보낸 **SVG**(`assets/icons/`)를 `flutter_svg`로 렌더. 색은 `AppSvg`의 `srcIn` 틴팅으로 동적 지정(원본 fill 무관).
- 이미지: `assets/images/`(PNG). 콘텐츠 사진은 더미.
- 새 UI는 기존 위젯/토큰을 먼저 재사용한다. 새 토큰이 필요하면 위 파일에 추가한다.

## Figma 소스

- fileKey `Em7O31AUCbcNOPtZvqmsCa` (`250703_지도감`). 메인(발견) 노드 `157:14432`, 컴포넌트 페이지 `365:10557`.
- Figma MCP는 **연결된 계정이 파일 편집(can edit) 권한**을 가져야 읽힌다(보기 권한만으론 실패). `whoami`로 계정 확인, 필요 시 `/mcp` 재연결.

## 컨벤션

- 작업 브랜치: `feat/<kebab-요약>` (그 외 `fix/`, `chore/`, `docs/`).
- PR은 `.github/PULL_REQUEST_TEMPLATE.md` 양식을 채운다. 베이스 브랜치는 `main`.
- 커밋/PR 전 `flutter analyze`와 `flutter test` 통과 확인.
- 주석·문서는 한국어를 쓴다(팀 컨벤션).

## 하지 말 것

- `assets/`, `lib/` 밖의 상위 사용자 폴더(특히 `/Dev`)를 수동 정리 맥락에서 건드리지 않는다.
- 색/간격/폰트를 위젯에 매직넘버로 박지 않는다 — 토큰을 쓴다.
