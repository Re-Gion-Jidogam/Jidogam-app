# 로그인/회원가입 바텀시트 — 설계 (UI 퍼블리싱 + 목 분기)

- 날짜: 2026-07-26
- 범위: 재사용 바텀시트 셸 + 인증 플로우(로그인/회원가입/비밀번호찾기). **백엔드 미연동(목 분기)**. 지도 4상태는 셸이 지원만 하고 구현 제외.
- Figma: 셸 `256:4060`, 이메일입력 `261:3598`, 로그인 `261:3730`, 인증번호 `275:6198`, 가입폼 `261:3871`, 가입중단 다이얼로그 `370:11182`, 가입완료 `275:6534`, 비밀번호찾기 `370:11405`/`370:11515`.

## 진입점
- 발견 홈 배너 "로그인해서 시작하기" 탭 → 공용 `showAuthSheet(context)`. 특정 화면에 종속되지 않는 모달 바텀시트(추후 프로필 등에서 재사용).

## 플로우 (상태머신)
```
emailEntry ──계속──▶ [등록됨?]
   │ (유효성 에러)      ├─ 예 ─▶ login(이메일 고정 + 비번) ──로그인──▶ (성공) 닫기·세션ON
   │                    │           └─ 비밀번호찾기 ─▶ findPwConfirm(네,맞아요) ─▶ findPwSent(로그인하기) ─▶ login
   │                    └─ 아니오 ─▶ verifyCode(인증번호, mm:ss) ──계속──▶
   │                                  signupForm(닉네임 중복확인·비번·비번확인) ──가입하기──▶ welcome(confetti) ──시작하기──▶ 닫기·세션ON
   └ signupForm에서 뒤로가기 → "회원가입 중단" 다이얼로그(취소 / 가입 중단)
```

## 목 규칙 (`AuthMockRepository` — 추후 API로 교체)
- `isEmailRegistered(email)`: 하드코딩 셋(`example@example.com` 등) 포함 여부.
- 이메일 유효성: 정규식. 실패 → "잘못된 이메일입니다".
- `verifyCode`: 6자리 숫자면 통과. 카운트다운 5:00, 만료 시 재전송.
- `checkNickname`: 2~15자 + 예약어(예: `admin`)만 사용중, 그 외 "사용 가능한 닉네임입니다".
- 비밀번호: 8자 이상, 확인 일치.
- 로그인/가입/비번찾기: 지연 후 성공 반환(목).

## 컴포넌트
- `core/widgets/app_bottom_sheet.dart` — 셸(blur/translucent, 상단 라운드20, 핸들, 원형 뒤로가기, 중앙 타이틀). 높이 모드 파라미터(45vh/95vh) 여지만.
- `core/widgets/app_text_field.dart` — 라벨+카운터+헬퍼, 상태(default/focus-valid=초록/error=빨강), trailing 슬롯(인증완료·타이머).
- `core/widgets/primary_button.dart` — 초록 CTA(enabled/disabled).
- `features/auth/`
  - `models/auth_state.dart` — step enum + 상태 데이터.
  - `data/auth_mock_repository.dart`, `data/auth_providers.dart`.
  - `application/auth_flow_controller.dart` — Notifier(step 전환, 타이머, 로딩/에러).
  - `presentation/auth_sheet.dart` — `showAuthSheet()` + step 스위칭.
  - `presentation/steps/*` — email_entry, login, verify_code, signup_form, welcome, find_password_confirm, find_password_sent.
  - `presentation/widgets/exit_signup_dialog.dart`, `confetti_overlay.dart`.

## 에셋
- confetti: `lottie` 패키지 + 무료 CC0 confetti Lottie 번들(`assets/lottie/confetti.json`). 특정 파일 있으면 교체.
- 아이콘: 뒤로가기 chevron(기존 SVG 재사용, 흰색 틴팅), 비번찾기 완료 체크(초록).

## 새 디자인 토큰
- `gray800 #52534E`(시트 타이틀), `red200 #F03E31`(에러 테두리), `red400 #BF1004`(에러 텍스트).

## 세션(목)
- 로그인/가입 성공 시 `sessionProvider`(isLoggedIn, nickname) ON + 시트 닫기. (홈 배너 로그인 상태 반영은 최소/후속.)

## 검증
- `flutter analyze` 0 issues, `flutter test` 통과, iPhone SE 시뮬레이터 실렌더 대조(각 step + 다이얼로그 + confetti).
