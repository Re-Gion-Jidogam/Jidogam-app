import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jidogam/app.dart';
import 'package:jidogam/core/widgets/primary_button.dart';
import 'package:jidogam/features/auth/application/session.dart';
import 'package:jidogam/features/map/presentation/widgets/place_detail_card.dart';
import 'package:jidogam/features/map/presentation/widgets/place_list_card.dart';

/// 다이얼로그의 확인 버튼(취소는 일반 텍스트, 확인만 [PrimaryButton]이라 이걸로
/// 유일하게 짚을 수 있다)을 탭한다. 이어서 성공 토스트의 자동 소멸 타이머
/// (2.3초)까지 시간을 흘려보낸다 — 토스트는 화면 갱신 없이 Timer로만
/// 사라지는 구간이 있어 pumpAndSettle이 조기에 "안정" 판정을 내리고 그
/// Timer를 테스트 종료 시점까지 남겨두기 때문에, 직접 그 이상 pump한다.
Future<void> _confirmDialog(WidgetTester tester) async {
  await tester.tap(
    find.descendant(
      of: find.byType(Dialog),
      matching: find.byType(PrimaryButton),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 2500));
  await tester.pumpAndSettle();
}

void main() {
  Future<String> pumpLoggedInExpandedCard(WidgetTester tester) async {
    final ProviderContainer container = ProviderContainer();
    container.read(sessionProvider.notifier).signIn(
          email: 'test@example.com',
          nickname: '테스터',
        );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const JidogamApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('지도'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('장소'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PlaceListCard).first);
    await tester.pumpAndSettle();

    final PlaceDetailCard card = find.byType(PlaceDetailCard).evaluate().first.widget
        as PlaceDetailCard;
    return card.place.name;
  }

  testWidgets('도장찍기 확인 다이얼로그에서 확정하면 카드가 "도장 지우기" 상태로 바뀐다',
      (WidgetTester tester) async {
    final String placeName = await pumpLoggedInExpandedCard(tester);

    await tester.ensureVisible(find.widgetWithText(PrimaryButton, '도장찍기'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(PrimaryButton, '도장찍기'));
    await tester.pumpAndSettle();

    // 확인 다이얼로그 — 장소명 + 쿨다운 안내 문구가 뜬다.
    expect(find.textContaining(placeName), findsWidgets);
    expect(find.textContaining('찍을 수 있어요'), findsOneWidget);

    await _confirmDialog(tester);

    expect(find.byType(Dialog), findsNothing);
    expect(find.text('도장 지우기'), findsOneWidget);
    expect(find.text('도장찍기'), findsNothing);
  });

  testWidgets('도장 지우기 확인 다이얼로그에서 확정하면 카드가 다시 "도장찍기" 상태로 돌아간다',
      (WidgetTester tester) async {
    await pumpLoggedInExpandedCard(tester);

    // 먼저 도장을 찍어 "도장 지우기" 상태로 만든다.
    await tester.ensureVisible(find.widgetWithText(PrimaryButton, '도장찍기'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(PrimaryButton, '도장찍기'));
    await tester.pumpAndSettle();
    await _confirmDialog(tester);
    expect(find.text('도장 지우기'), findsOneWidget);

    // 도장 지우기 → 확인 다이얼로그(빨강 경고 문구) → 확정.
    await tester.ensureVisible(find.text('도장 지우기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('도장 지우기'));
    await tester.pumpAndSettle();
    expect(find.text('지운 후에는 복구할 수 없어요.'), findsOneWidget);

    await _confirmDialog(tester);

    expect(find.byType(Dialog), findsNothing);
    expect(find.text('도장찍기'), findsOneWidget);
    expect(find.text('도장 지우기'), findsNothing);
  });
}
