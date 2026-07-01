import 'package:flutter_test/flutter_test.dart';

import 'package:jidogam/main.dart';

void main() {
  testWidgets('App boots and renders home page', (WidgetTester tester) async {
    await tester.pumpWidget(const JidogamApp());

    expect(find.byType(HomePage), findsOneWidget);
  });
}
