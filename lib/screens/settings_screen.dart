import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_enums.dart';
import '../state/settings_state.dart';
import '../widgets/bracket_title.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsState>();

    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const BracketTitle('PARAMETRES'),
            const Text('Événements spéciaux',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            for (final type in EventType.values)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(type.label),
                value: settings.enabledEvents.contains(type),
                onChanged: (value) => settings.setEventEnabled(type, value),
              ),
            const SizedBox(height: 24),
            const Text('Fréquence des événements',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Slider(
              value:
                  EventFrequency.values.indexOf(settings.frequency).toDouble(),
              min: 0,
              max: (EventFrequency.values.length - 1).toDouble(),
              divisions: EventFrequency.values.length - 1,
              label: settings.frequency.label,
              onChanged: (value) => settings
                  .setFrequency(EventFrequency.values[value.round()]),
            ),
            Center(
              child: Text(settings.frequency.label,
                  style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
