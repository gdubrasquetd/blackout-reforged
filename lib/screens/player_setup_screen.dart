import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/player.dart';
import '../state/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/bracket_title.dart';
import '../widgets/stacked_button.dart';
import 'mode_screen.dart';

class _PlayerSlot {
  final TextEditingController controller;
  Gender gender;
  _PlayerSlot({String name = '', this.gender = Gender.female})
      : controller = TextEditingController(text: name);
}

/// Player roster screen. Unlike the original app -- which hard-wired
/// exactly 10 EditText/ToggleButton pairs and revealed them one at a time --
/// this is a real dynamic list with no arbitrary player cap.
class PlayerSetupScreen extends StatefulWidget {
  final bool resume;
  const PlayerSetupScreen({super.key, this.resume = false});

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  final List<_PlayerSlot> _slots = [];

  @override
  void initState() {
    super.initState();
    if (widget.resume) {
      final existing = context.read<GameState>().players;
      for (final p in existing) {
        _slots.add(_PlayerSlot(name: p.name, gender: p.gender));
      }
    }
    while (_slots.length < 2) {
      _slots.add(_PlayerSlot());
    }
  }

  @override
  void dispose() {
    for (final s in _slots) {
      s.controller.dispose();
    }
    super.dispose();
  }

  void _addSlot() => setState(() => _slots.add(_PlayerSlot()));

  void _removeSlot(int index) {
    setState(() {
      _slots[index].controller.dispose();
      _slots.removeAt(index);
    });
  }

  void _onNext() {
    final players = <Player>[];
    for (final slot in _slots) {
      final name = slot.controller.text.trim();
      if (name.isNotEmpty) {
        players.add(Player(name: name, gender: slot.gender));
      }
    }
    if (players.length < 2) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Pas assez de joueurs'),
          content: const Text(
              'Il faut au moins 2 joueurs pour commencer une partie.'),
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
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ModeScreen(players: players)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        top: false,
        child: Column(
            children: [
              const BracketTitle('JOUEURS'),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _slots.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _PlayerRow(
                    slot: _slots[index],
                    onRemove:
                        _slots.length > 2 ? () => _removeSlot(index) : null,
                    onGenderChanged: (gender) =>
                        setState(() => _slots[index].gender = gender),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: StackedButton(
                  onPressed: _addSlot,
                  height: 48,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: AppTheme.accent),
                      SizedBox(width: 8),
                      Text('Ajouter un joueur'),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: StackedButton(
                  onPressed: _onNext,
                  child: const Text('Jouer'),
                ),
              ),
            ],
          ),
        ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  final _PlayerSlot slot;
  final VoidCallback? onRemove;
  final ValueChanged<Gender> onGenderChanged;

  const _PlayerRow({
    required this.slot,
    required this.onRemove,
    required this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: slot.controller,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'Prénom'),
          ),
        ),
        const SizedBox(width: 8),
        SegmentedButton<Gender>(
          segments: const [
            ButtonSegment(value: Gender.male, label: Text('H')),
            ButtonSegment(value: Gender.female, label: Text('F')),
          ],
          selected: {slot.gender},
          onSelectionChanged: (selection) => onGenderChanged(selection.first),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: onRemove,
          color: onRemove == null ? Colors.transparent : null,
        ),
      ],
    );
  }
}
