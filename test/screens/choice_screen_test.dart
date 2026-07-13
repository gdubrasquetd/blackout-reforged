import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blackout/models/game_enums.dart';
import 'package:blackout/models/player.dart';
import 'package:blackout/screens/card_screen.dart';
import 'package:blackout/screens/choice_screen.dart';
import 'package:blackout/screens/home_screen.dart';
import 'package:blackout/state/game_state.dart';

import '../helpers/fake_content_repository.dart';
import '../helpers/pump_app.dart';

Future<GameState> readyGameState() async {
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
  return state;
}

void main() {
  testWidgets('picks a player and shows Action / Au pif / Vérité buttons',
      (tester) async {
    final gameState = await readyGameState();
    await pumpApp(tester, const ChoiceScreen(), gameState: gameState);
    await tester.pumpAndSettle();

    expect(find.text('Action'), findsOneWidget);
    expect(find.text('Au pif'), findsOneWidget);
    expect(find.text('Vérité'), findsOneWidget);
    expect(gameState.currentPlayer, isNotNull);
    expect(find.text(gameState.currentPlayer!.name), findsOneWidget);
  });

  testWidgets('tapping Action navigates to CardScreen(isAction: true)',
      (tester) async {
    final gameState = await readyGameState();
    await pumpApp(tester, const ChoiceScreen(), gameState: gameState);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Action'));
    await tester.pumpAndSettle();

    final cardScreen = tester.widget<CardScreen>(find.byType(CardScreen));
    expect(cardScreen.isAction, isTrue);
  });

  testWidgets('tapping Vérité navigates to CardScreen(isAction: false)',
      (tester) async {
    final gameState = await readyGameState();
    await pumpApp(tester, const ChoiceScreen(), gameState: gameState);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Vérité'));
    await tester.pumpAndSettle();

    final cardScreen = tester.widget<CardScreen>(find.byType(CardScreen));
    expect(cardScreen.isAction, isFalse);
  });

  testWidgets('tapping Au pif navigates to a CardScreen', (tester) async {
    final gameState = await readyGameState();
    await pumpApp(tester, const ChoiceScreen(), gameState: gameState);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Au pif'));
    await tester.pumpAndSettle();

    expect(find.byType(CardScreen), findsOneWidget);
  });

  testWidgets('the home icon returns to HomeScreen and clears the stack',
      (tester) async {
    final gameState = await readyGameState();
    await pumpApp(tester, const ChoiceScreen(), gameState: gameState);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(ChoiceScreen), findsNothing);
  });
}
