import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blackout/widgets/stacked_button.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('renders its child content', (tester) async {
    await tester.pumpWidget(wrap(
      StackedButton(onPressed: () {}, child: const Text('Jouer')),
    ));
    expect(find.text('Jouer'), findsOneWidget);
  });

  testWidgets('invokes onPressed when tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(wrap(
      StackedButton(onPressed: () => tapped = true, child: const Text('Go')),
    ));
    await tester.tap(find.text('Go'));
    expect(tapped, isTrue);
  });

  testWidgets('does not throw and is inert when onPressed is null',
      (tester) async {
    await tester.pumpWidget(wrap(
      const StackedButton(onPressed: null, child: Text('Disabled')),
    ));
    // Tapping a disabled button should not throw.
    await tester.tap(find.text('Disabled'));
    await tester.pump();
    expect(find.text('Disabled'), findsOneWidget);
  });

  testWidgets('respects a custom height', (tester) async {
    await tester.pumpWidget(wrap(
      StackedButton(onPressed: () {}, height: 100, child: const Text('Tall')),
    ));
    final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
    expect(sizedBox.height, 108); // height + 8 offset
  });
}
