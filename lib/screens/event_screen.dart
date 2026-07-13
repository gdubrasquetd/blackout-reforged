import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_enums.dart';
import '../state/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/home_icon_button.dart';
import '../widgets/stacked_button.dart';
import 'choice_screen.dart';
import 'home_screen.dart';

/// Shows a special-event card (Duel/Dilemme/Tournée/Mini-jeu/Pouvoir).
/// Replaces 5 near-identical Activities from the original app that only
/// differed in which content pool they drew from.
class EventScreen extends StatefulWidget {
  final EventType eventType;
  const EventScreen({super.key, required this.eventType});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  late final String _text;

  @override
  void initState() {
    super.initState();
    _text = context.read<GameState>().drawEventCard(widget.eventType);
  }

  void _goToChoice() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ChoiceScreen()),
    );
  }

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.accent, width: 4),
        ),
        child: SafeArea(
          child: Column(
            children: [
              HomeIconButton(onPressed: _goHome),
                Center(
                  child: Text(
                    widget.eventType.label.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: AppTheme.displayFont,
                      fontSize: 38,
                      color: AppTheme.accent,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const Spacer(),
                        Text(
                          _text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 22),
                        ),
                        const Spacer(),
                        StackedButton(
                          onPressed: _goToChoice,
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
      ),
    );
  }
}
