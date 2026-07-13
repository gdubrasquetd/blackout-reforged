import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/home_icon_button.dart';
import '../widgets/stacked_button.dart';
import 'card_screen.dart';
import 'home_screen.dart';

/// Core loop screen: picks the next player, shows a bit of gendered flavor
/// text, then lets them choose Action / Vérité / Aléatoire.
class ChoiceScreen extends StatefulWidget {
  const ChoiceScreen({super.key});

  @override
  State<ChoiceScreen> createState() => _ChoiceScreenState();
}

class _ChoiceScreenState extends State<ChoiceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<GameState>().nextTurn();
    });
  }

  void _goToCard(bool isAction) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => CardScreen(isAction: isAction)),
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
    final gameState = context.watch<GameState>();
    final player = gameState.currentPlayer;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            HomeIconButton(onPressed: _goHome),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: player == null
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          children: [
                            const Spacer(),
                            Text(
                              player.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: AppTheme.displayFont,
                                fontSize: 58,
                                color: Color(0xFFF5E9DC),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              gameState.currentTransitionText ?? '',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const Spacer(),
                            StackedButton(
                              onPressed: () => _goToCard(true),
                              child: const Text('Action'),
                            ),
                            const SizedBox(height: 16),
                            StackedButton(
                              onPressed: () =>
                                  _goToCard(Random().nextBool()),
                              child: const Text('Au pif'),
                            ),
                            const SizedBox(height: 16),
                            StackedButton(
                              onPressed: () => _goToCard(false),
                              child: const Text('Vérité'),
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
