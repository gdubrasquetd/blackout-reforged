import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../error_reporting.dart';
import '../models/game_enums.dart';
import '../models/player.dart';
import '../state/game_state.dart';
import '../state/settings_state.dart';
import '../theme/app_theme.dart';
import '../widgets/bracket_title.dart';
import '../widgets/stacked_button.dart';
import 'choice_screen.dart';

class ModeScreen extends StatefulWidget {
  final List<Player> players;
  const ModeScreen({super.key, required this.players});

  @override
  State<ModeScreen> createState() => _ModeScreenState();
}

class _ModeScreenState extends State<ModeScreen> {
  final Set<Difficulty> _selected = {};
  bool _loading = false;

  Future<void> _onPlay() async {
    if (_selected.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sélection de mode'),
          content:
              const Text('Vous devez sélectionner au moins un mode de jeu.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _loading = true);
    final settings = context.read<SettingsState>();
    final gameState = context.read<GameState>();
    try {
      await gameState.startNewGame(
        players: widget.players,
        difficulties: _selected,
        customActions: settings.customActions,
        customVerites: settings.customVerites,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ChoiceScreen()),
      );
    } catch (error, stackTrace) {
      reportError(error, stackTrace, context: 'ModeScreen._onPlay');
      if (!mounted) return;
      setState(() => _loading = false);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erreur de chargement'),
          content: const Text(
              "Impossible de charger le contenu du jeu. Réessayez, et si le "
              "problème persiste, réinstallez l'application."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
              children: [
                const BracketTitle('PACKS'),
                const Text(
                  'Sélectionnez un ou plusieurs packs d\'actions/vérités de votre choix.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _DifficultyTile(
                          emoji: '🍺',
                          label: 'Soft',
                          description: 'Ambiance légère, pour bien démarrer',
                          selected: _selected.contains(Difficulty.soft),
                          onChanged: (v) => setState(() {
                            v
                                ? _selected.add(Difficulty.soft)
                                : _selected.remove(Difficulty.soft);
                          }),
                        ),
                        const SizedBox(height: 12),
                        _DifficultyTile(
                          emoji: '🍷',
                          label: 'Medium',
                          description: 'Ça commence à chauffer',
                          selected: _selected.contains(Difficulty.medium),
                          onChanged: (v) => setState(() {
                            v
                                ? _selected.add(Difficulty.medium)
                                : _selected.remove(Difficulty.medium);
                          }),
                        ),
                        const SizedBox(height: 12),
                        _DifficultyTile(
                          emoji: '🥃',
                          label: 'Hard',
                          description: 'Aucune limite',
                          selected: _selected.contains(Difficulty.hard),
                          onChanged: (v) => setState(() {
                            v
                                ? _selected.add(Difficulty.hard)
                                : _selected.remove(Difficulty.hard);
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: StackedButton(
                    onPressed: _loading ? null : _onPlay,
                    child: _loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Jouer'),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}

class _DifficultyTile extends StatelessWidget {
  final String emoji;
  final String label;
  final String description;
  final bool selected;
  final ValueChanged<bool> onChanged;

  const _DifficultyTile({
    required this.emoji,
    required this.label,
    required this.description,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!selected),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.surface
              : AppTheme.background.withValues(alpha: 0.4),
          border: Border.all(
            color: selected ? AppTheme.accent : Colors.white24,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(description,
                      style:
                          TextStyle(color: Colors.white.withValues(alpha: 0.7))),
                ],
              ),
            ),
            Checkbox(value: selected, onChanged: (v) => onChanged(v ?? false)),
          ],
        ),
      ),
    );
  }
}
