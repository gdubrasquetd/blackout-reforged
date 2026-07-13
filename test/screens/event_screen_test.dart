import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blackout/models/game_enums.dart';
import 'package:blackout/models/player.dart';
import 'package:blackout/screens/choice_screen.dart';
import 'package:blackout/screens/event_screen.dart';
import 'package:blackout/screens/home_screen.dart';
import 'package:blackout/state/game_state.dart';

import '../helpers/fake_content_repository.dart';
import '../helpers/pump_app.dart';
import '../helpers/zero_random.dart';

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
  for (final type in EventType.values) {
    testWidgets('renders the ${type.name} label and its card text',
        (tester) async {
      final gameState = await readyGameStateOnTurn();
      await pumpApp(tester, EventScreen(eventType: type),
          gameState: gameState);

      expect(find.text(type.label.toUpperCase()), findsOneWidget);
      expect(find.text("C'est fait !"), findsOneWidget);
    });
  }

  testWidgets('tapping "C\'est fait !" navigates back to ChoiceScreen',
      (tester) async {
    final gameState = await readyGameStateOnTurn();
    await pumpApp(tester, const EventScreen(eventType: EventType.duel),
        gameState: gameState);

    await tester.tap(find.text("C'est fait !"));
    await tester.pumpAndSettle();

    expect(find.byType(ChoiceScreen), findsOneWidget);
  });

  testWidgets('the home icon returns to HomeScreen', (tester) async {
    final gameState = await readyGameStateOnTurn();
    await pumpApp(tester, const EventScreen(eventType: EventType.role),
        gameState: gameState);

    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('the screen is framed by an accent-colored border',
      (tester) async {
    final gameState = await readyGameStateOnTurn();
    await pumpApp(tester, const EventScreen(eventType: EventType.global),
        gameState: gameState);

    final container = tester.widget<Container>(find.byType(Container).first);
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.border, isNotNull);
  });

  testWidgets('duel event substitutes two player names', (tester) async {
    final state = GameState(
      repository: FakeContentRepository(
        eventsByType: {
          for (final t in EventType.values) t: ['t'],
          EventType.duel: ['%s contre %2\$s'],
        },
      ),
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

    await pumpApp(tester, const EventScreen(eventType: EventType.duel),
        gameState: state);

    expect(find.text('Alice contre Bob'), findsOneWidget);
  });
}
