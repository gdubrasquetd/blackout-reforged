import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blackout/screens/home_screen.dart';
import 'package:blackout/screens/starting_screen.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('shows the BlackOut title and a Commencer button',
      (tester) async {
    await pumpApp(tester, const StartingScreen());
    expect(find.text('BlackOut'), findsOneWidget);
    expect(find.text('Commencer'), findsOneWidget);
  });

  testWidgets('tapping Commencer shows the age/alcohol disclaimer dialog',
      (tester) async {
    await pumpApp(tester, const StartingScreen());
    await tester.tap(find.text('Commencer'));
    await tester.pumpAndSettle();

    expect(find.text('Attention'), findsOneWidget);
    expect(find.textContaining("L'abus d'alcool"), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
    expect(find.text('Quitter'), findsOneWidget);
  });

  testWidgets('the disclaimer cannot be dismissed by tapping the barrier',
      (tester) async {
    await pumpApp(tester, const StartingScreen());
    await tester.tap(find.text('Commencer'));
    await tester.pumpAndSettle();

    // Tap far from the dialog content (the barrier).
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(find.text('Attention'), findsOneWidget);
  });

  testWidgets('accepting the disclaimer navigates to HomeScreen',
      (tester) async {
    await pumpApp(tester, const StartingScreen());
    await tester.tap(find.text('Commencer'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(StartingScreen), findsNothing);
  });
}
