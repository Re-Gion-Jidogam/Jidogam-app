import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jidogam/app.dart';
import 'package:jidogam/features/auth/application/session.dart';
import 'package:jidogam/features/cta/cta_page.dart';
import 'package:jidogam/features/map/models/place.dart';
import 'package:jidogam/features/map/presentation/widgets/place_detail_card.dart';
import 'package:jidogam/features/map/presentation/widgets/place_list_card.dart';
import 'package:jidogam/features/profile/data/user_profile_repository.dart';

void main() {
  testWidgets('장소 카드를 탭하면 다른 카드는 그대로 남긴 채 그 카드만 상세로 커지고, 다시 탭하면 접힌다',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: JidogamApp()));
    await tester.pumpAndSettle();

    // 지도 탭 → 장소 세그먼트로 이동.
    await tester.tap(find.text('지도'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('장소'));
    await tester.pumpAndSettle();

    // 목록이 보이고, 상세 카드는 아직 없다.
    final int totalPlaces = tester.widgetList(find.byType(PlaceListCard)).length;
    expect(totalPlaces, greaterThan(1));
    expect(find.byType(PlaceDetailCard), findsNothing);

    // 첫 카드를 탭하면 페이지 이동 없이 그 카드만 상세로 커진다 —
    // 나머지 카드는 목록 카드로 그대로 남는다.
    await tester.tap(find.byType(PlaceListCard).first);
    await tester.pumpAndSettle();

    expect(find.byType(PlaceDetailCard), findsOneWidget);
    expect(find.byType(PlaceListCard), findsNWidgets(totalPlaces - 1));
    // 비로그인 상태 기본값 → 버튼은 전체 너비 "나도 도장찍기" CTA 1개뿐.
    expect(find.text('나도 도장찍기'), findsOneWidget);
    expect(find.text('내 가이드북에 추가'), findsNothing);
    expect(find.text('도장찍기'), findsNothing);
    expect(find.textContaining('이 장소가 포함된 가이드북'), findsOneWidget);

    // 상세 카드의 헤더(이름)를 다시 탭하면 목록 카드로 접힌다.
    final Place selectedPlace =
        (find.byType(PlaceDetailCard).evaluate().first.widget as PlaceDetailCard)
            .place;
    await tester.tap(find.text(selectedPlace.name).first);
    await tester.pumpAndSettle();

    expect(find.byType(PlaceDetailCard), findsNothing);
    expect(find.byType(PlaceListCard), findsNWidgets(totalPlaces));
  });

  testWidgets('비로그인 상태에서 "나도 도장찍기"를 탭하면 CTA 화면으로 이동한다',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: JidogamApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('지도'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('장소'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PlaceListCard).first);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('나도 도장찍기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('나도 도장찍기'));
    await tester.pumpAndSettle();

    expect(find.byType(CtaPage), findsOneWidget);
  });

  testWidgets('로그인 상태에서는 "도장찍기" 라벨로 바뀐다',
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
    await tester.tap(find.text('장소'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PlaceListCard).first);
    await tester.pumpAndSettle();

    expect(find.text('도장찍기'), findsOneWidget);
    expect(find.text('내 가이드북에 추가'), findsOneWidget);
    expect(find.text('나도 도장찍기'), findsNothing);
  });

  testWidgets('마지막으로 도장 찍은 지 쿨다운(5분) 이내면 "장소" 탭 헤더 아래에 안내 문구가 뜬다',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          lastStampedAtProvider.overrideWithValue(DateTime.now()),
        ],
        child: const JidogamApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('지도'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('장소'));
    await tester.pumpAndSettle();

    expect(find.text('5분 뒤에 도장을 찍을 수 있어요'), findsOneWidget);
  });
}
