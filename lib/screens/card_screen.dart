import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/game_state.dart';
import '../state/settings_state.dart';
import '../theme/app_theme.dart';
import '../widgets/home_icon_button.dart';
import '../widgets/stacked_button.dart';
import 'choice_screen.dart';
import 'home_screen.dart';
import 'transition_screen.dart';

/// Shows an Action or Vérité card for the current player. Also owns the
/// "should a special event interrupt now?" decision on "Suivant", which the
/// original app duplicated verbatim between ActionPage and VeritePage.
class CardScreen extends StatefulWidget {
  final bool isAction;
  const CardScreen({super.key, required this.isAction});

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  late final String _text;

  @override
  void initState() {
    super.initState();
    final gameState = context.read<GameState>();
    _text = widget.isAction ? gameState.drawAction() : gameState.drawVerite();
  }

  void _onNext() {
    final gameState = context.read<GameState>();
    final settings = context.read<SettingsState>();
    final eventType = gameState.maybeTriggerEvent(
      frequency: settings.frequency,
      enabledTypes: settings.enabledEvents,
    );
    if (eventType != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (_) => TransitionScreen(eventType: eventType)),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ChoiceScreen()),
      );
    }
  }

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            HomeIconButton(onPressed: _goHome),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 32),
                      Text(
                        gameState.currentPlayer?.name ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: AppTheme.displayFont,
                          fontSize: 58,
                          color: AppTheme.accent,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 22),
                      ),
                      const Spacer(),
                      StackedButton(
                        onPressed: _onNext,
                        child: const Text("C'est fait !"),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
