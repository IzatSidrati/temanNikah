import 'package:flutter_test/flutter_test.dart';
import 'package:nikah_plan/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NikahPlanApp());
    expect(find.text('TemanNikah'), findsWidgets);
  });
}
