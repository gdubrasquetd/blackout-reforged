import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blackout/models/player.dart';
import 'package:blackout/screens/mode_screen.dart';
import 'package:blackout/screens/player_setup_screen.dart';
import 'package:blackout/state/game_state.dart';

import '../helpers/fake_content_repository.dart';
import '../helpers/pump_app.dart';

void main() {
  testWidgets('shows the JOUEURS title and 2 empty player fields by default',
      (tester) async {
    await pumpApp(tester, const PlayerSetupScreen());
    expect(find.text('JOUEURS'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Prénom'), findsNWidgets(2)); // hint text on both fields
  });

  testWidgets('resume=true pre-fills fields from the existing roster',
      (tester) async {
    final gameState = GameState(repository: FakeContentRepository())
      ..players = const [
        Player(name: 'Alice', gender: Gender.female),
        Player(name: 'Bob', gender: Gender.male),
        Player(name: 'Carla', gender: Gender.female),
      ];
    await pumpApp(
      tester,
      const PlayerSetupScreen(resume: true),
      gameState: gameState,
    );

    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
    expect(find.text('Carla'), findsOneWidget);
  });

  testWidgets('"Ajouter un joueur" adds a new empty field', (tester) async {
    await pumpApp(tester, const PlayerSetupScreen());
    expect(find.byType(TextField), findsNWidgets(2));

    await tester.tap(find.text('Ajouter un joueur'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNWidgets(3));
  });

  testWidgets('the remove (X) button is not usable while only 2 players exist',
      (tester) async {
    await pumpApp(tester, const PlayerSetupScreen());
    final closeButtons = find.widgetWithIcon(IconButton, Icons.close);
    expect(closeButtons, findsNWidgets(2));

    final firstButton = tester.widget<IconButton>(closeButtons.first);
    expect(firstButton.onPressed, isNull);
  });

  testWidgets('removing a slot after adding a 3rd player works', (tester) async {
    await pumpApp(tester, const PlayerSetupScreen());
    await tester.tap(find.text('Ajouter un joueur'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(3));

    final closeButtons = find.widgetWithIcon(IconButton, Icons.close);
    await tester.tap(closeButtons.last);
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets('tapping Jouer with fewer than 2 named players shows a warning',
      (tester) async {
    await pumpApp(tester, const PlayerSetupScreen());
    await tester.enterText(find.byType(TextField).at(0), 'Alice');
    // Second field left empty.

    await tester.tap(find.text('Jouer'));
    await tester.pumpAndSettle();

    expect(find.text('Pas assez de joueurs'), findsOneWidget);
    expect(find.byType(ModeScreen), findsNothing);
  });

  testWidgets('tapping Jouer with 2 named players navigates to ModeScreen',
      (tester) async {
    await pumpApp(tester, const PlayerSetupScreen());
    await tester.enterText(find.byType(TextField).at(0), 'Alice');
    await tester.enterText(find.byType(TextField).at(1), 'Bob');

    await tester.tap(find.text('Jouer'));
    await tester.pumpAndSettle();

    expect(find.byType(ModeScreen), findsOneWidget);
  });

  testWidgets('blank-named slots are ignored when counting players',
      (tester) async {
    await pumpApp(tester, const PlayerSetupScreen());
    await tester.tap(find.text('Ajouter un joueur'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Alice');
    await tester.enterText(find.byType(TextField).at(1), '   ');
    await tester.enterText(find.byType(TextField).at(2), 'Bob');

    await tester.tap(find.text('Jouer'));
    await tester.pumpAndSettle();

    // Alice + Bob is enough; the blank-named middle slot doesn't count but
    // also doesn't block progress.
    expect(find.byType(ModeScreen), findsOneWidget);
  });

  testWidgets('default gender for a new slot is female (F selected)',
      (tester) async {
    await pumpApp(tester, const PlayerSetupScreen());
    final segmented =
        tester.widgetList<SegmentedButton<Gender>>(find.byType(SegmentedButton<Gender>));
    for (final s in segmented) {
      expect(s.selected, {Gender.female});
    }
  });
}
