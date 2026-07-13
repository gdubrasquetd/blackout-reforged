import 'package:flutter_test/flutter_test.dart';

import 'package:blackout/main.dart';

void main() {
  testWidgets('App boots to the disclaimer screen', (WidgetTester tester) async {
    await tester.pumpWidget(const BlackOutApp());
    await tester.pump();

    expect(find.text('BlackOut'), findsOneWidget);
    expect(find.text('Commencer'), findsOneWidget);
  });
}
