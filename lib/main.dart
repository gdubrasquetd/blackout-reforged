import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'error_reporting.dart';
import 'screens/starting_screen.dart';
import 'state/game_state.dart';
import 'state/settings_state.dart';
import 'theme/app_theme.dart';

void main() {
  runGuarded(() => runApp(const BlackOutApp()));
}

class BlackOutApp extends StatelessWidget {
  const BlackOutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameState()),
        ChangeNotifierProvider(create: (_) => SettingsState()..load()),
      ],
      child: MaterialApp(
        title: 'BlackOut',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const StartingScreen(),
      ),
    );
  }
}
