import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jidogam/app.dart';
import 'package:jidogam/features/auth/application/session.dart';
import 'package:jidogam/features/home/widgets/guidebook_card.dart';
import 'package:jidogam/features/map/presentation/widgets/guidebook_filter_chip.dart';
import 'package:jidogam/features/map/presentation/widgets/guidebook_promo_card.dart';

void main() {
  testWidgets(
      '비로그인 상태 — 프로모 카드는 "당신을 기다리는 곳"으로 뜨고, "도전중인 가이드북" 섹션은 아예 안 뜬다',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: JidogamApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('지도'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('가이드북'));
    await tester.pumpAndSettle();

    expect(find.text('멋진 가이드북을 검색해보세요'), findsOneWidget);
    expect(find.byType(GuidebookPromoCard), findsNWidgets(2));
    expect(find.text('인기 가이드북'), findsOneWidget);
    expect(find.textContaining('당신을'), findsOneWidget);
    expect(find.textContaining('지나가던 사람'), findsNothing);

    // 내가 참여 중인 가이드북 섹션이라 비로그인이면 통째로 안 보인다.
    expect(find.text('도전중인 가이드북'), findsNothing);
    expect(find.byType(GuidebookFilterChip), findsNothing);
    expect(find.byType(GuidebookCard), findsNothing);
  });

  testWidgets('로그인 상태 — 프로모 카드/가이드북 카드에 실제 닉네임이 뜨고, "도전중인 가이드북" 섹션이 보인다',
      (WidgetTester tester) async {
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
    await tester.tap(find.text('가이드북'));
    await tester.pumpAndSettle();

    expect(find.textContaining('지나가던 사람'), findsNothing);
    expect(find.textContaining('테스터님을'), findsOneWidget);

    expect(find.text('도전중인 가이드북'), findsOneWidget);
    expect(find.byType(GuidebookFilterChip), findsNWidgets(2));
    expect(find.text('출판됨'), findsOneWidget);
    expect(find.text('비공개'), findsOneWidget);

    final int cardCount = tester.widgetList(find.byType(GuidebookCard)).length;
    expect(cardCount, greaterThan(1));
    // "도전중인 가이드북"은 전부 완료 전이라 카드마다 별점 대신 진행률
    // 배지("N% 완료")가 뜬다.
    expect(find.textContaining('% 완료'), findsNWidgets(cardCount));
    expect(find.textContaining('Lv. 3132 · 테스터'), findsWidgets);
  });
}
