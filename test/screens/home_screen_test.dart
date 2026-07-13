import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blackout/models/player.dart';
import 'package:blackout/screens/about_screen.dart';
import 'package:blackout/screens/home_screen.dart';
import 'package:blackout/screens/personalize_screen.dart';
import 'package:blackout/screens/player_setup_screen.dart';
import 'package:blackout/screens/settings_screen.dart';
import 'package:blackout/state/game_state.dart';

import '../helpers/fake_content_repository.dart';
import '../helpers/pump_app.dart';

void main() {
  testWidgets('renders the title and all four menu buttons', (tester) async {
    await pumpApp(tester, const HomeScreen());
    expect(find.text('BlackOut'), findsOneWidget);
    expect(find.text('Jouer'), findsOneWidget);
    expect(find.text('Boutique'), findsOneWidget);
    expect(find.text('Paramètres'), findsOneWidget);
    expect(find.text('Personnaliser'), findsOneWidget);
  });

  testWidgets('Jouer with no ongoing game goes straight to PlayerSetupScreen',
      (tester) async {
    await pumpApp(tester, const HomeScreen());
    await tester.tap(find.text('Jouer'));
    await tester.pumpAndSettle();

    expect(find.byType(PlayerSetupScreen), findsOneWidget);
    // No "resume or new" dialog should have appeared.
    expect(find.text('Lancer une partie'), findsNothing);
  });

  testWidgets('Jouer with an ongoing game asks to resume or start over',
      (tester) async {
    final gameState = GameState(repository: FakeContentRepository())
      ..players = const [
        Player(name: 'Alice', gender: Gender.female),
        Player(name: 'Bob', gender: Gender.male),
      ];
    await pumpApp(tester, const HomeScreen(), gameState: gameState);

    await tester.tap(find.text('Jouer'));
    await tester.pumpAndSettle();

    expect(find.text('Lancer une partie'), findsOneWidget);
    expect(find.text('Reprendre'), findsOneWidget);
    expect(find.text('Nouvelle partie'), findsOneWidget);
  });

  testWidgets('choosing Reprendre opens PlayerSetupScreen in resume mode',
      (tester) async {
    final gameState = GameState(repository: FakeContentRepository())
      ..players = const [
        Player(name: 'Alice', gender: Gender.female),
        Player(name: 'Bob', gender: Gender.male),
      ];
    await pumpApp(tester, const HomeScreen(), gameState: gameState);

    await tester.tap(find.text('Jouer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reprendre'));
    await tester.pumpAndSettle();

    expect(find.byType(PlayerSetupScreen), findsOneWidget);
    // Existing player names should be pre-filled.
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
  });

  testWidgets('choosing Nouvelle partie opens an empty PlayerSetupScreen',
      (tester) async {
    final gameState = GameState(repository: FakeContentRepository())
      ..players = const [
        Player(name: 'Alice', gender: Gender.female),
        Player(name: 'Bob', gender: Gender.male),
      ];
    await pumpApp(tester, const HomeScreen(), gameState: gameState);

    await tester.tap(find.text('Jouer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nouvelle partie'));
    await tester.pumpAndSettle();

    expect(find.byType(PlayerSetupScreen), findsOneWidget);
    expect(find.text('Alice'), findsNothing);
  });

  testWidgets('Boutique navigates to AboutScreen', (tester) async {
    await pumpApp(tester, const HomeScreen());
    await tester.tap(find.text('Boutique'));
    await tester.pumpAndSettle();
    expect(find.byType(AboutScreen), findsOneWidget);
  });

  testWidgets('Paramètres navigates to SettingsScreen', (tester) async {
    await pumpApp(tester, const HomeScreen());
    await tester.tap(find.text('Paramètres'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  testWidgets('Personnaliser navigates to PersonalizeScreen', (tester) async {
    await pumpApp(tester, const HomeScreen());
    await tester.tap(find.text('Personnaliser'));
    await tester.pumpAndSettle();
    expect(find.byType(PersonalizeScreen), findsOneWidget);
  });
}
