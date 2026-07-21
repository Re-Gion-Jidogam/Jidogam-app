import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jidogam/app.dart';
import 'package:jidogam/features/home/home_page.dart';

void main() {
  testWidgets('앱이 부팅되고 홈(발견) 화면이 렌더된다', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: JidogamApp()));
    await tester.pump();

    // 홈 화면과 주요 섹션/네비게이션 라벨이 보인다.
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('당신을 기다리는 곳'), findsOneWidget);
    expect(find.text('인기 가이드북'), findsOneWidget);
    expect(find.text('인기 장소'), findsOneWidget);
    expect(find.text('발견'), findsOneWidget);
    expect(find.text('프로필'), findsOneWidget);
  });
}
