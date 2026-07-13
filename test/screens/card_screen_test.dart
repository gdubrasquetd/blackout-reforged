import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blackout/models/game_enums.dart';
import 'package:blackout/models/player.dart';
import 'package:blackout/screens/card_screen.dart';
import 'package:blackout/screens/choice_screen.dart';
import 'package:blackout/screens/home_screen.dart';
import 'package:blackout/screens/transition_screen.dart';
import 'package:blackout/state/game_state.dart';
import 'package:blackout/state/settings_state.dart';

import '../helpers/fake_content_repository.dart';
import '../helpers/pump_app.dart';
import '../helpers/zero_random.dart';

Future<GameState> readyGameStateOnTurn({
  FakeContentRepository? repository,
}) async {
  final state = GameState(
    repository: repository ?? FakeContentRepository(),
    random: const ZeroRandom(),
  );
  await state.startNewGame(
    players: const [
      Player(name: 'Alice', gender: Gender.female),
      Player(name: 'Bob', gender: Gender.male),
    ],
    difficulties: {Difficulty.soft},
    customActions: const [],
    customVerites: const [],
  );
  state.nextTurn();
  return state;
}

void main() {
  testWidgets('shows the current player name and an action card',
      (tester) async {
    final gameState = await readyGameStateOnTurn(
      repository: FakeContentRepository(
        actionsByDifficulty: {
          Difficulty.soft: ['Fixed action card'],
          Difficulty.medium: ['m'],
          Difficulty.hard: ['h'],
        },
      ),
    );
    await pumpApp(tester, const CardScreen(isAction: true),
        gameState: gameState);

    expect(find.text(gameState.currentPlayer!.name), findsOneWidget);
    expect(find.text('Fixed action card'), findsOneWidget);
    expect(find.text("C'est fait !"), findsOneWidget);
  });

  testWidgets('shows a vérité card when isAction is false', (tester) async {
    final gameState = await readyGameStateOnTurn(
      repository: FakeContentRepository(
        veritesByDifficulty: {
          Difficulty.soft: ['Fixed vérité card'],
          Difficulty.medium: ['m'],
          Difficulty.hard: ['h'],
        },
      ),
    );
    await pumpApp(tester, const CardScreen(isAction: false),
        gameState: gameState);

    expect(find.text('Fixed vérité card'), findsOneWidget);
  });

  testWidgets(
      'tapping "C\'est fait !" with no event goes back to ChoiceScreen',
      (tester) async {
    final gameState = await readyGameStateOnTurn();
    final settings = SettingsState()..frequency = EventFrequency.none;
    await pumpApp(
      tester,
      const CardScreen(isAction: true),
      gameState: gameState,
      settingsState: settings,
    );

    await tester.tap(find.text("C'est fait !"));
    await tester.pumpAndSettle();

    expect(find.byType(ChoiceScreen), findsOneWidget);
    expect(find.byType(TransitionScreen), findsNothing);
  });

  testWidgets(
      'tapping "C\'est fait !" when an event is due navigates to '
      'TransitionScreen', (tester) async {
    final gameState = await readyGameStateOnTurn();
    final settings = SettingsState()..frequency = EventFrequency.veryHigh;

    // Prime the 3-turn cooldown so the very next roll (made by the widget's
    // own onPressed handler) is eligible to trigger. ZeroRandom guarantees
    // the probability roll always succeeds once the cooldown has passed.
    for (var i = 0; i < 3; i++) {
      gameState.maybeTriggerEvent(
        frequency: settings.frequency,
        enabledTypes: settings.enabledEvents,
      );
    }

    await pumpApp(
      tester,
      const CardScreen(isAction: true),
      gameState: gameState,
      settingsState: settings,
    );

    await tester.tap(find.text("C'est fait !"));
    await tester.pumpAndSettle();

    expect(find.byType(TransitionScreen), findsOneWidget);
    expect(find.byType(ChoiceScreen), findsNothing);
  });

  testWidgets('the home icon returns to HomeScreen', (tester) async {
    final gameState = await readyGameStateOnTurn();
    await pumpApp(tester, const CardScreen(isAction: true),
        gameState: gameState);

    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(CardScreen), findsNothing);
  });
}
