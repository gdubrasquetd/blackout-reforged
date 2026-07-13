import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/stacked_button.dart';
import '../widgets/tiled_background.dart';
import 'about_screen.dart';
import 'personalize_screen.dart';
import 'player_setup_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final hasOngoingGame = gameState.players.isNotEmpty;

    return Scaffold(
      body: TiledBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'BlackOut',
                    style: TextStyle(
                      fontFamily: AppTheme.displayFont,
                      fontSize: 120,
                      color: AppTheme.accent,
                    ),
                  ),
                ),
                const Spacer(),
                StackedButton(
                  onPressed: () => _onPlay(context, hasOngoingGame),
                  child: const Text('Jouer'),
                ),
                const SizedBox(height: 16),
                StackedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_cart_outlined,
                          color: AppTheme.accent),
                      SizedBox(width: 10),
                      Text('Boutique'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                StackedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.settings_outlined, color: AppTheme.accent),
                      SizedBox(width: 10),
                      Text('Paramètres'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                StackedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const PersonalizeScreen()),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.brush_outlined, color: AppTheme.accent),
                      SizedBox(width: 10),
                      Text('Personnaliser'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onPlay(BuildContext context, bool hasOngoingGame) async {
    if (!hasOngoingGame) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PlayerSetupScreen()),
      );
      return;
    }

    final resume = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lancer une partie'),
        content: const Text(
          'Souhaitez-vous reprendre la partie en cours ou en démarrer une nouvelle ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Nouvelle partie'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reprendre'),
          ),
        ],
      ),
    );

    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PlayerSetupScreen(resume: resume ?? false),
        ),
      );
    }
  }
}
