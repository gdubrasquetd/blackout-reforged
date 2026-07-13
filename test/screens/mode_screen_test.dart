import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blackout/models/player.dart';
import 'package:blackout/screens/choice_screen.dart';
import 'package:blackout/screens/mode_screen.dart';
import 'package:blackout/state/game_state.dart';

import '../helpers/fake_content_repository.dart';
import '../helpers/pump_app.dart';

const players = [
  Player(name: 'Alice', gender: Gender.female),
  Player(name: 'Bob', gender: Gender.male),
];

void main() {
  testWidgets('renders the PACKS title, instructions and 3 difficulty tiles',
      (tester) async {
    await pumpApp(tester, const ModeScreen(players: players));
    expect(find.text('PACKS'), findsOneWidget);
    expect(find.textContaining('Sélectionnez un ou plusieurs packs'),
        findsOneWidget);
    expect(find.text('Soft'), findsOneWidget);
    expect(find.text('Medium'), findsOneWidget);
    expect(find.text('Hard'), findsOneWidget);
    expect(find.text('Jouer'), findsOneWidget);
  });

  testWidgets('tapping Jouer with no pack selected shows a warning dialog',
      (tester) async {
    await pumpApp(tester, const ModeScreen(players: players));
    await tester.tap(find.text('Jouer'));
    await tester.pumpAndSettle();
    expect(find.text('Sélection de mode'), findsOneWidget);
    expect(find.byType(ChoiceScreen), findsNothing);
  });

  testWidgets('selecting Soft toggles its checkbox on', (tester) async {
    await pumpApp(tester, const ModeScreen(players: players));
    final checkboxFinder = find.byType(Checkbox).first;
    expect(tester.widget<Checkbox>(checkboxFinder).value, isFalse);

    await tester.tap(find.text('Soft'));
    await tester.pump();

    expect(tester.widget<Checkbox>(checkboxFinder).value, isTrue);
  });

  testWidgets('selecting a pack and tapping Jouer starts the game and '
      'navigates to ChoiceScreen', (tester) async {
    final gameState = GameState(repository: FakeContentRepository());
    await pumpApp(
      tester,
      const ModeScreen(players: players),
      gameState: gameState,
    );

    await tester.tap(find.text('Soft'));
    await tester.pump();
    await tester.tap(find.text('Jouer'));
    await tester.pumpAndSettle();

    expect(find.byType(ChoiceScreen), findsOneWidget);
    expect(gameState.isReady, isTrue);
    expect(gameState.players, players);
  });

  testWidgets('multiple packs can be selected at once', (tester) async {
    await pumpApp(tester, const ModeScreen(players: players));
    await tester.tap(find.text('Soft'));
    await tester.pump();
    await tester.tap(find.text('Medium'));
    await tester.pump();

    final checkboxes = tester.widgetList<Checkbox>(find.byType(Checkbox));
    final checkedCount = checkboxes.where((c) => c.value == true).length;
    expect(checkedCount, 2);
  });
}
