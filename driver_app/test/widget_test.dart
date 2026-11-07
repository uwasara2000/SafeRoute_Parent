import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/main.dart';

void main() {
  testWidgets('Driver App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SafeRouteDriverApp());
    expect(find.byType(SafeRouteDriverApp), findsOneWidget);
  });
}
