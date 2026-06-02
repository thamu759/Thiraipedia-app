import 'package:flutter_test/flutter_test.dart';
import 'package:thiraipedia_app/app.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ThiraiPediaApp());
    expect(find.text('thiraipedia'), findsWidgets);
  });
}
