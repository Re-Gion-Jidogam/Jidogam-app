import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jidogam/app.dart';
import 'package:jidogam/core/widgets/circle_back_button.dart';
import 'package:jidogam/core/widgets/primary_button.dart';
import 'package:jidogam/features/auth/application/session.dart';
import 'package:jidogam/features/cta/cta_page.dart';
import 'package:jidogam/features/home/models/guidebook.dart';
import 'package:jidogam/features/home/widgets/guidebook_card.dart';
import 'package:jidogam/features/map/presentation/guidebook_detail_page.dart';
import 'package:jidogam/features/map/presentation/review_write_page.dart';
import 'package:jidogam/features/map/presentation/widgets/guidebook_place_card.dart';
import 'package:jidogam/features/map/presentation/widgets/guidebook_review_card.dart';

/// 도전 전 상태 테스트용 가이드북(앱 더미는 전부 도전 중).
const Guidebook _freshGuidebook = Guidebook(
  title: '테스트 가이드북',
  level: 1,
  authorName: '작성자',
  rating: 4.0,
  placeCount: 10,
  publishedDate: '2025. 01. 01',
  rewardPoint: 100,
  background: EmojiBackground(color: Color(0xFFFFFF99), emoji: '🎉'),
);

void main() {
  testWidgets('로그인 상태에서 "도전중인 가이드북" 카드를 탭하면 상세 화면이 열린다',
      (WidgetTester tester) async {
    final ProviderContainer container = ProviderContainer();
    container.read(sessionProvider.notifier).signIn(
          email: 'test@example.com',
          nickname: '테스터',
        );
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const JidogamApp()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('지도'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('가이드북'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(GuidebookCard).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(GuidebookCard).first);
    await tester.pumpAndSettle();

    expect(find.byType(GuidebookDetailPage), findsOneWidget);
    expect(find.text('도전 취소'), findsOneWidget);
    expect(find.text('리뷰쓰기'), findsOneWidget);
    // 10곳 중 2곳 방문 → 20%.
    expect(find.text('20% 완료'), findsOneWidget);
    expect(find.text('2 / 10'), findsOneWidget);
    final FractionallySizedBox fill = tester.widget(find.descendant(
      of: find.byType(ProgressBadge),
      matching: find.byType(FractionallySizedBox),
    ));
    expect(fill.widthFactor, closeTo(0.2, 0.001));

    // 뒤로가기 버튼으로 닫힌다.
    await tester.tap(find.byType(CircleBackButton));
    await tester.pumpAndSettle();
    expect(find.byType(GuidebookDetailPage), findsNothing);
  });

  testWidgets('비로그인 상태에선 "나도 도전하기" 버튼 하나뿐이고, 탭하면 CTA 화면으로 이동한다',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: GuidebookDetailPage(_freshGuidebook)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('나도 도전하기'), findsOneWidget);
    expect(find.text('도전하기'), findsNothing);
    expect(find.text('리뷰쓰기'), findsNothing);

    await tester.tap(find.text('나도 도전하기'));
    await tester.pumpAndSettle();

    expect(find.byType(CtaPage), findsOneWidget);
  });

  testWidgets('로그인 상태에서 "도전하기"를 탭하면 "도전 취소"+진행률로 바뀌고, 다시 탭하면 되돌아간다',
      (WidgetTester tester) async {
    final ProviderContainer container = ProviderContainer();
    container.read(sessionProvider.notifier).signIn(
          email: 'test@example.com',
          nickname: '테스터',
        );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: GuidebookDetailPage(_freshGuidebook)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('도전하기'), findsOneWidget);
    expect(find.text('도전 취소'), findsNothing);
    // 도전 전엔 리뷰쓰기 없음.
    expect(find.text('리뷰쓰기'), findsNothing);

    await tester.tap(find.text('도전하기'));
    await tester.pumpAndSettle();

    expect(find.text('도전 취소'), findsOneWidget);
    expect(find.text('0% 완료'), findsOneWidget);
    expect(find.text('리뷰쓰기'), findsOneWidget);
    expect(find.text(' 도전을 시작했어요'), findsOneWidget);

    // 토스트 타이머 소진.
    await tester.pump(const Duration(seconds: 3));
    expect(find.text(' 도전을 시작했어요'), findsNothing);

    // 다이얼로그에서 "취소"면 도전 유지.
    await tester.tap(find.text('도전 취소'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('도전을 취소할까요?'), findsOneWidget);
    expect(find.text('다시 도전하면 달성 경험치가\n지금과 달라질 수 있어요.'),
        findsOneWidget);

    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    expect(find.text('0% 완료'), findsOneWidget);

    // "도전 취소"로 확정하면 되돌아간다.
    await tester.tap(find.text('도전 취소'));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(
      of: find.byType(Dialog),
      matching: find.widgetWithText(PrimaryButton, '도전 취소'),
    ));
    await tester.pumpAndSettle();
    expect(find.text(' 도전을 취소했어요'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));

    expect(find.text('도전하기'), findsOneWidget);
    expect(find.text('도전 취소'), findsNothing);
    expect(find.text('리뷰쓰기'), findsNothing);
  });

  testWidgets('가이드북 제목이 좌상단 뒤로가기 버튼과 겹치지 않는다',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: GuidebookDetailPage(_freshGuidebook)),
      ),
    );
    await tester.pumpAndSettle();

    final Rect backButtonRect = tester.getRect(find.byType(CircleBackButton));
    final Rect titleRect = tester.getRect(find.text(_freshGuidebook.title));
    expect(backButtonRect.overlaps(titleRect), isFalse);
  });

  testWidgets('"방문완료"/"미방문" 필터를 탭하면 장소 리스트가 걸러진다',
      (WidgetTester tester) async {
    final ProviderContainer container = ProviderContainer();
    container.read(sessionProvider.notifier).signIn(
          email: 'test@example.com',
          nickname: '테스터',
        );
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const JidogamApp()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('지도'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('가이드북'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(GuidebookCard).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(GuidebookCard).first);
    await tester.pumpAndSettle();

    expect(find.byType(GuidebookDetailPage), findsOneWidget);

    // 아래쪽 항목은 아직 빌드 전이라 ensureVisible 대신 드래그로 찾는다.
    await tester.dragUntilVisible(
      find.text('방문완료'),
      find.byType(Scrollable).first, // 세로 시트 스크롤(리뷰 가로 스크롤과 구분).
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    final int totalPlaces =
        tester.widgetList(find.byType(GuidebookPlaceCard)).length;
    expect(totalPlaces, greaterThan(0));

    await tester.tap(find.text('방문완료'));
    await tester.pumpAndSettle();
    final int visitedOnly =
        tester.widgetList(find.byType(GuidebookPlaceCard)).length;
    expect(visitedOnly, lessThan(totalPlaces));
    expect(visitedOnly, greaterThan(0));
    // 방문완료 카드엔 방문일이 붙는다.
    expect(find.textContaining('에 도장찍음'), findsNWidgets(visitedOnly));

    // 미방문 카드엔 없다.
    await tester.tap(find.text('미방문'));
    await tester.pumpAndSettle();
    expect(find.byType(GuidebookPlaceCard), findsWidgets);
    expect(find.textContaining('에 도장찍음'), findsNothing);
    await tester.tap(find.text('미방문'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('방문완료'));
    await tester.pumpAndSettle();

    // 재탭하면 필터 해제.
    await tester.tap(find.text('방문완료'));
    await tester.pumpAndSettle();
    expect(
      tester.widgetList(find.byType(GuidebookPlaceCard)).length,
      totalPlaces,
    );
  });

  testWidgets('"리뷰쓰기"로 별점+본문을 입력해 등록하면 리뷰 목록 맨 앞에 추가된다',
      (WidgetTester tester) async {
    final ProviderContainer container = ProviderContainer();
    container.read(sessionProvider.notifier).signIn(
          email: 'test@example.com',
          nickname: '테스터',
        );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: GuidebookDetailPage(_freshGuidebook)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('도전하기'));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // 리뷰가 없으면 안내 문구.
    await tester.dragUntilVisible(
      find.text('아직 등록된 리뷰가 없어요'),
      find.byType(Scrollable).first,
      const Offset(0, -200),
    );
    // 제목은 "리뷰".
    expect(find.text('리뷰'), findsOneWidget);
    expect(find.text('0개의 리뷰'), findsNothing);
    await tester.dragUntilVisible(
      find.text('리뷰쓰기'),
      find.byType(Scrollable).first,
      const Offset(0, 200),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('리뷰쓰기'));
    await tester.pumpAndSettle();
    expect(find.byType(ReviewWritePage), findsOneWidget);

    // 별점·본문 모두 있어야 "등록" 활성.
    PrimaryButton submit() =>
        tester.widget(find.widgetWithText(PrimaryButton, '등록'));
    expect(submit().onPressed, isNull);

    await tester.tap(find.byKey(const ValueKey<String>('review-star-4')));
    await tester.pump();
    expect(submit().onPressed, isNull);

    await tester.enterText(
      find.descendant(
        of: find.byType(ReviewWritePage),
        matching: find.byType(TextField),
      ),
      '정말 좋았어요',
    );
    await tester.pump();
    expect(submit().onPressed, isNotNull);

    await tester.tap(find.widgetWithText(PrimaryButton, '등록'));
    await tester.pumpAndSettle();

    expect(find.byType(ReviewWritePage), findsNothing);
    expect(find.text('1개의 리뷰'), findsOneWidget);
    // 리뷰 카드가 빌드되도록 스크롤.
    await tester.dragUntilVisible(
      find.byType(GuidebookReviewCard),
      find.byType(Scrollable).first,
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    final GuidebookReviewCard card =
        tester.widget(find.byType(GuidebookReviewCard).first);
    expect(card.review.rating, 4.0);
    expect(card.review.content, '정말 좋았어요');
    expect(card.review.authorName, '테스터');
    expect(find.text('아직 등록된 리뷰가 없어요'), findsNothing);
    expect(find.text('에 리뷰를 남겼어요'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('리뷰 작성 중 뒤로가면 확인 다이얼로그가 뜨고, 입력이 없으면 바로 닫힌다',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    const ReviewWritePage(guidebookTitle: '테스트 가이드북'),
              ),
            ),
            child: const Text('열기'),
          ),
        ),
      ),
    );
    Future<void> open() async {
      await tester.tap(find.text('열기'));
      await tester.pumpAndSettle();
      expect(find.byType(ReviewWritePage), findsOneWidget);
    }

    final Finder back = find.byKey(const ValueKey<String>('review-write-back'));

    // 뒤로가기와 타이틀이 겹치지 않는다.
    await open();
    expect(
      tester.getRect(back).overlaps(tester.getRect(find.text('리뷰쓰기'))),
      isFalse,
    );
    await tester.tap(back);
    await tester.pumpAndSettle();

    // 입력이 없으면 바로 닫힌다.
    await open();
    await tester.tap(back);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    expect(find.byType(ReviewWritePage), findsNothing);

    // 입력 후 뒤로가기 → 다이얼로그, "취소"면 유지.
    await open();
    await tester.tap(find.byKey(const ValueKey<String>('review-star-3')));
    await tester.pump();
    await tester.tap(back);
    await tester.pumpAndSettle();
    expect(find.text('지금 나가면 작성한 내용이 사라져요.'), findsOneWidget);
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
    expect(find.byType(ReviewWritePage), findsOneWidget);

    // 시스템 뒤로가기도 동일, "나가기"면 닫힌다.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    await tester.tap(find.text('나가기'));
    await tester.pumpAndSettle();
    expect(find.byType(ReviewWritePage), findsNothing);
  });
}
