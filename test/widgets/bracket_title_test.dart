import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blackout/widgets/bracket_title.dart';

void main() {
  testWidgets('renders the given title text', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: BracketTitle('JOUEURS')),
    ));
    expect(find.text('JOUEURS'), findsOneWidget);
  });

  testWidgets('renders the corner-bracket painter', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: BracketTitle('PACKS')),
    ));
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('renders long titles without throwing', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: BracketTitle('PERSONNALISER')),
    ));
    expect(find.text('PERSONNALISER'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
