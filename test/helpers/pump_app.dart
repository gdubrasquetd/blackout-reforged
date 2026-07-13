import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:blackout/state/game_state.dart';
import 'package:blackout/state/settings_state.dart';
import 'package:blackout/theme/app_theme.dart';

import 'fake_content_repository.dart';

/// Pumps [child] wrapped the same way `main.dart` wires the real app:
/// MultiProvider(GameState, SettingsState) + MaterialApp with the app theme.
///
/// Tests can pass a pre-configured [gameState] (e.g. already past
/// `startNewGame`) to drop directly into mid-game screens without repeating
/// setup navigation.
Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  GameState? gameState,
  SettingsState? settingsState,
}) async {
  SharedPreferences.setMockInitialValues({});
  final settings = settingsState ?? SettingsState();
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<GameState>.value(
          value: gameState ?? GameState(repository: FakeContentRepository()),
        ),
        ChangeNotifierProvider<SettingsState>.value(value: settings),
      ],
      child: MaterialApp(
        theme: AppTheme.dark,
        home: child,
      ),
    ),
  );
}
