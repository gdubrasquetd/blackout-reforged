import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/settings_state.dart';
import '../widgets/bracket_title.dart';

/// Custom actions/vérités editor. The original app capped this at exactly
/// 10 hard-wired button/text pairs shared between both categories; here
/// each category gets its own list with a saner cap
/// ([SettingsState.maxCustomEntries]), and entries persist across restarts.
class PersonalizeScreen extends StatelessWidget {
  const PersonalizeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const BracketTitle('PERSONNALISER'),
            _CustomSection(isAction: true, title: 'Actions personnalisées'),
            const SizedBox(height: 24),
            _CustomSection(isAction: false, title: 'Vérités personnalisées'),
          ],
        ),
      ),
    );
  }
}

class _CustomSection extends StatelessWidget {
  final bool isAction;
  final String title;
  const _CustomSection({required this.isAction, required this.title});

  String _applyTags(String text) {
    return text
        .replaceAll('%', ' ')
        .replaceAll('-A', '%s')
        .replaceAll('-O', '%2\$s')
        .replaceAll('-S', '%3\$s')
        .replaceAll('-H', '%4\$s')
        .replaceAll('-F', '%5\$s');
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final controller = TextEditingController();
    final settings = context.read<SettingsState>();

    final String? text;
    try {
      text = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(isAction ? 'Ajouter une action' : 'Ajouter une vérité'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Texte...'),
              ),
              const SizedBox(height: 12),
              const Text(
                'Balises disponibles pour cibler une personne :\n'
                '"-A" Aléatoire   "-O" Sexe opposé   "-S" Même sexe\n'
                '"-H" Homme   "-F" Femme',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      // The dialog's exit transition is still animating -- and the
      // autofocused TextField still holds focus -- for a frame or two after
      // this Future completes. Disposing the controller synchronously here
      // pulls it out from under the still-active TextField mid-transition.
      // Deferring to the next frame lets the route finish tearing itself
      // down first.
      WidgetsBinding.instance.addPostFrameCallback((_) => controller.dispose());
    }

    if (text == null || text.isEmpty || !context.mounted) return;

    final formatted = '${_applyTags(text)}\n\nOu bois 3 gorgées !';
    final added = settings.addCustom(isAction: isAction, text: formatted);
    if (!added && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Limite de ${SettingsState.maxCustomEntries} entrées atteinte.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsState>();
    final entries = isAction ? settings.customActions : settings.customVerites;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _showAddDialog(context),
            ),
          ],
        ),
        if (entries.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Aucune entrée pour le moment.',
                style: TextStyle(color: Colors.white54)),
          ),
        for (var i = 0; i < entries.length; i++)
          Card(
            child: ListTile(
              title: Text(
                entries[i],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () =>
                    settings.removeCustom(isAction: isAction, index: i),
              ),
            ),
          ),
      ],
    );
  }
}
