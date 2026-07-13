import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blackout/models/game_enums.dart';
import 'package:blackout/models/player.dart';
import 'package:blackout/screens/event_screen.dart';
import 'package:blackout/screens/transition_screen.dart';
import 'package:blackout/state/game_state.dart';

import '../helpers/fake_content_repository.dart';
import '../helpers/pump_app.dart';

Future<GameState> readyGameStateOnTurn() async {
  final state = GameState(repository: FakeContentRepository());
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
  testWidgets('renders without throwing for every event type', (tester) async {
    for (final type in EventType.values) {
      final gameState = await readyGameStateOnTurn();
      await pumpApp(tester, TransitionScreen(eventType: type),
          gameState: gameState);
      expect(tester.takeException(), isNull);
      // Cancel the pending auto-advance timer before moving to the next
      // iteration by disposing the widget tree.
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('automatically advances to EventScreen after 4 seconds',
      (tester) async {
    final gameState = await readyGameStateOnTurn();
    await pumpApp(
      tester,
      const TransitionScreen(eventType: EventType.duel),
      gameState: gameState,
    );

    expect(find.byType(EventScreen), findsNothing);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(find.byType(EventScreen), findsOneWidget);
  });

  testWidgets('tapping the screen advances to EventScreen immediately',
      (tester) async {
    final gameState = await readyGameStateOnTurn();
    await pumpApp(
      tester,
      const TransitionScreen(eventType: EventType.role),
      gameState: gameState,
    );

    await tester.tap(find.byType(TransitionScreen));
    await tester.pumpAndSettle();

    expect(find.byType(EventScreen), findsOneWidget);
  });

  testWidgets('does not throw if disposed before the timer fires',
      (tester) async {
    final gameState = await readyGameStateOnTurn();
    await pumpApp(
      tester,
      const TransitionScreen(eventType: EventType.dilem),
      gameState: gameState,
    );

    // Unmount before the 4-second timer completes.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 5));

    expect(tester.takeException(), isNull);
  });
}
