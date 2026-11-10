import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saferoute_parent/app.dart';

void main() {
  testWidgets('SafeRouteApp renders Journey History screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SafeRouteApp());

    // Verify the app renders with the Journey History title
    expect(find.text('Journey History'), findsOneWidget);

    // Verify the bottom navigation bar is present with 5 tabs
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Track'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Alerts'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // Unmount widget tree to cancel periodic timers and clean up
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
