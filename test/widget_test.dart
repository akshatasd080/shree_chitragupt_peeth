import 'package:flutter_test/flutter_test.dart';
import 'package:shree_chitragupt_peeth/app/app.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ShreeChitraguptPeethApp(),
    );

    expect(find.text('श्री चित्रगुप्त पीठ'), findsOneWidget);
  });
}