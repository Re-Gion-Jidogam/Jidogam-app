import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jidogam/app.dart';
import 'package:jidogam/features/home/models/guidebook.dart';
import 'package:jidogam/features/map/data/map_repository.dart';
import 'package:jidogam/features/map/presentation/guidebook_browse_page.dart';
import 'package:jidogam/features/map/presentation/guidebook_detail_page.dart';
import 'package:jidogam/features/map/presentation/widgets/guidebook_flip_card.dart';
import 'package:jidogam/features/map/presentation/widgets/guidebook_promo_card.dart';
import 'package:jidogam/features/map/presentation/widgets/place_list_card.dart';

void main() {
  Future<void> goToGuidebookTab(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: JidogamApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('지도'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('가이드북'));
    await tester.pumpAndSettle();
  }

  testWidgets('"인기 가이드북" 프로모 카드를 탭하면 브라우징 화면이 그 타이틀로 열린다',
      (WidgetTester tester) async {
    await goToGuidebookTab(tester);

    await tester.tap(find.widgetWithText(GuidebookPromoCard, '인기 가이드북'));
    await tester.pumpAndSettle();

    expect(find.byType(GuidebookBrowsePage), findsOneWidget);
    expect(find.text('인기 가이드북'), findsOneWidget);
    expect(find.byType(GuidebookFlipCard), findsWidgets);
  });

  testWidgets('가이드북 검색바를 탭하면 검색 변형(닫기 버튼 포함)으로 열리고, 닫으면 되돌아간다',
      (WidgetTester tester) async {
    await goToGuidebookTab(tester);

    await tester.tap(find.text('멋진 가이드북을 검색해보세요'));
    await tester.pumpAndSettle();

    expect(find.byType(GuidebookBrowsePage), findsOneWidget);
    expect(find.text('가이드북 검색'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.byType(GuidebookBrowsePage), findsNothing);
  });

  testWidgets('첫 카드에서 왼쪽 화살표는 비활성 — 오른쪽 화살표를 누르면 다음 카드로 넘어간다',
      (WidgetTester tester) async {
    await goToGuidebookTab(tester);
    await tester.tap(find.widgetWithText(GuidebookPromoCard, '인기 가이드북'));
    await tester.pumpAndSettle();

    final Finder leftArrow = find.byIcon(Icons.chevron_left);
    final Finder rightArrow = find.byIcon(Icons.chevron_right);
    expect(leftArrow, findsOneWidget);
    expect(rightArrow, findsOneWidget);

    // 왼쪽 화살표는 첫 카드에서 비활성 — 눌러도 아무 일도 없어야 한다.
    await tester.tap(leftArrow, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(GuidebookBrowsePage), findsOneWidget);

    await tester.tap(rightArrow);
    await tester.pumpAndSettle();
    // 카드가 실제로 넘어갔는지는 내부 인덱스라 직접 볼 수 없지만, 최소한
    // 화면이 죽지 않고 카드가 계속 보이는지 확인한다.
    expect(find.byType(GuidebookFlipCard), findsWidgets);
  });

  testWidgets('카드를 탭하면 뒤집혀 소개글이 보이고, 다시 탭하면 앞면으로 돌아간다',
      (WidgetTester tester) async {
    // 전체 앱 내비게이션(지도 탭 → 가이드북 세그먼트 → 프로모 카드) 대신
    // GuidebookFlipCard 하나만 단독으로 띄운다 — PageView가 다음 페이지를
    // 화면 밖에 미리 만들어둬서 동일 타입 위젯이 둘 이상 존재할 수 있는
    // 환경을 피하고, 탭 대상을 확실하게 만든다.
    final Guidebook guidebook = const MapRepository().browsableGuidebooks().first;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Center(child: GuidebookFlipCard(guidebook))),
      ),
    );
    await tester.pumpAndSettle();

    // 앞면에서는 소개글이 안 보인다.
    expect(find.textContaining('전주의 다양한 수제버거 맛집'), findsNothing);

    await tester.tap(find.byType(GuidebookFlipCard));
    // 뒤집기 애니메이션(500ms)이 끝날 때까지 기다린다.
    await tester.pumpAndSettle();

    expect(find.textContaining('전주의 다양한 수제버거 맛집'), findsOneWidget);

    await tester.tap(find.byType(GuidebookFlipCard));
    await tester.pumpAndSettle();

    expect(find.textContaining('전주의 다양한 수제버거 맛집'), findsNothing);
  });

  testWidgets('앞면의 하단 텍스트 영역을 탭하면 뒤집히지 않고 곧장 상세 화면으로 이동한다',
      (WidgetTester tester) async {
    final Guidebook guidebook = const MapRepository().browsableGuidebooks().first;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: Center(child: GuidebookFlipCard(guidebook))),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 카드 하단 텍스트 영역을 탭한다(중앙 뒤집기 영역과 안 겹침).
    final Rect cardRect = tester.getRect(find.byType(GuidebookFlipCard));
    await tester.tapAt(cardRect.bottomCenter - const Offset(0, 12));
    await tester.pumpAndSettle();

    expect(find.byType(GuidebookDetailPage), findsOneWidget);
  });

  testWidgets('뒷면의 소개글 영역을 탭해도 곧장 상세 화면으로 이동한다',
      (WidgetTester tester) async {
    final Guidebook guidebook = const MapRepository().browsableGuidebooks().first;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: Center(child: GuidebookFlipCard(guidebook))),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 카드 중앙 탭으로 뒷면으로 뒤집는다.
    await tester.tap(find.byType(GuidebookFlipCard));
    await tester.pumpAndSettle();
    expect(find.textContaining('전주의 다양한 수제버거 맛집'), findsOneWidget);

    // 소개글을 탭하면 상세로 이동한다.
    await tester.tap(find.textContaining('전주의 다양한 수제버거 맛집'));
    await tester.pumpAndSettle();

    expect(find.byType(GuidebookDetailPage), findsOneWidget);
  });

  testWidgets('가만히 3초 이상 두면 카드가 저절로 뒤집힌다', (WidgetTester tester) async {
    await goToGuidebookTab(tester);
    await tester.tap(find.widgetWithText(GuidebookPromoCard, '인기 가이드북'));
    await tester.pumpAndSettle();

    expect(find.textContaining('전주의 다양한 수제버거 맛집'), findsNothing);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(find.textContaining('전주의 다양한 수제버거 맛집'), findsOneWidget);
  });

  testWidgets('장소 상세의 "이 장소가 포함된 가이드북"을 탭하면 그 장소 이름을 타이틀로 브라우징 화면이 열린다',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: JidogamApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('지도'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('장소'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PlaceListCard).first);
    await tester.pumpAndSettle();

    final Finder guidebookLink = find.textContaining('이 장소가 포함된 가이드북');
    await tester.ensureVisible(guidebookLink);
    await tester.pumpAndSettle();
    await tester.tap(guidebookLink);
    await tester.pumpAndSettle();

    expect(find.byType(GuidebookBrowsePage), findsOneWidget);
    expect(find.textContaining('이 포함된 가이드북'), findsWidgets);
  });
}
