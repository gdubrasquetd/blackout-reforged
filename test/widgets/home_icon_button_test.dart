import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blackout/widgets/home_icon_button.dart';

void main() {
  testWidgets('renders a home icon', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: HomeIconButton(onPressed: () {})),
    ));
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
  });

  testWidgets('invokes onPressed when tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: HomeIconButton(onPressed: () => tapped = true)),
    ));
    await tester.tap(find.byIcon(Icons.home_outlined));
    expect(tapped, isTrue);
  });
}
