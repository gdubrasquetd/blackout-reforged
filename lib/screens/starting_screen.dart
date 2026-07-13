import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../widgets/stacked_button.dart';
import '../widgets/tiled_background.dart';
import 'home_screen.dart';

/// First screen shown: the legal/age disclaimer, ported verbatim in intent
/// from the original app. Must be accepted before entering the app.
class StartingScreen extends StatelessWidget {
  const StartingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TiledBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'BlackOut',
                  style: TextStyle(
                    fontFamily: AppTheme.displayFont,
                    fontSize: 48,
                    color: AppTheme.accent,
                  ),
                ),
                const SizedBox(height: 32),
                StackedButton(
                  onPressed: () => _showDisclaimer(context),
                  child: const Text('Commencer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDisclaimer(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Attention'),
        content: const SingleChildScrollView(
          child: Text(
            "L'abus d'alcool est dangereux pour la santé. En poursuivant vous "
            'confirmez être en âge de consommer de l\'alcool et vous assumez '
            'être seuls responsables des éventuelles conséquences que pourrait '
            "engendrer l'utilisation de BlackOut.\n\n"
            "Les quantités d'alcool sont seulement indicatives et ne sont en "
            'aucun cas obligatoires.\n\n'
            'Vous vous engagez à ne pousser ou ne forcer personne à consommer '
            "de l'alcool.",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text('Quitter'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
