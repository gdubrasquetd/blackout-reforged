import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:blackout/models/game_enums.dart';
import 'package:blackout/screens/settings_screen.dart';
import 'package:blackout/state/settings_state.dart';

import '../helpers/pump_app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('renders the PARAMETRES title and all 5 event switches',
      (tester) async {
    final settings = SettingsState();
    await settings.load();
    await pumpApp(tester, const SettingsScreen(), settingsState: settings);

    expect(find.text('PARAMETRES'), findsOneWidget);
    for (final type in EventType.values) {
      expect(find.text(type.label), findsOneWidget);
    }
    expect(find.byType(SwitchListTile), findsNWidgets(EventType.values.length));
  });

  testWidgets('all switches start enabled by default', (tester) async {
    final settings = SettingsState();
    await settings.load();
    await pumpApp(tester, const SettingsScreen(), settingsState: settings);

    final switches =
        tester.widgetList<SwitchListTile>(find.byType(SwitchListTile));
    expect(switches.every((s) => s.value), isTrue);
  });

  testWidgets('toggling a switch disables that event type', (tester) async {
    final settings = SettingsState();
    await settings.load();
    await pumpApp(tester, const SettingsScreen(), settingsState: settings);

    await tester.tap(find.widgetWithText(SwitchListTile, EventType.duel.label));
    await tester.pump();

    expect(settings.enabledEvents.contains(EventType.duel), isFalse);
    final duelSwitch = tester.widget<SwitchListTile>(
      find.widgetWithText(SwitchListTile, EventType.duel.label),
    );
    expect(duelSwitch.value, isFalse);
  });

  testWidgets('shows the current frequency label', (tester) async {
    final settings = SettingsState()..frequency = EventFrequency.high;
    await pumpApp(tester, const SettingsScreen(), settingsState: settings);
    expect(find.text('Fréquent'), findsOneWidget);
  });

  testWidgets('dragging the slider updates the frequency', (tester) async {
    final settings = SettingsState();
    await settings.load();
    await pumpApp(tester, const SettingsScreen(), settingsState: settings);

    final slider = find.byType(Slider);
    // Drag to the far right end: should land on the highest frequency.
    await tester.drag(slider, const Offset(500, 0));
    await tester.pump();

    expect(settings.frequency, EventFrequency.veryHigh);
  });
}
