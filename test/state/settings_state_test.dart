import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:blackout/models/game_enums.dart';
import 'package:blackout/state/settings_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SettingsState defaults', () {
    test('starts with every event enabled and normal frequency', () {
      final settings = SettingsState();
      expect(settings.enabledEvents, EventType.values.toSet());
      expect(settings.frequency, EventFrequency.normal);
      expect(settings.customActions, isEmpty);
      expect(settings.customVerites, isEmpty);
      expect(settings.loaded, isFalse);
    });
  });

  group('SettingsState.load', () {
    test('marks loaded=true and notifies listeners', () async {
      final settings = SettingsState();
      var notified = false;
      settings.addListener(() => notified = true);
      await settings.load();
      expect(settings.loaded, isTrue);
      expect(notified, isTrue);
    });

    test('restores previously persisted values', () async {
      SharedPreferences.setMockInitialValues({
        'enabled_events': ['duel', 'role'],
        'event_frequency': 'veryHigh',
        'custom_actions': '["a1","a2"]',
        'custom_verites': '["v1"]',
      });
      final settings = SettingsState();
      await settings.load();

      expect(settings.enabledEvents, {EventType.duel, EventType.role});
      expect(settings.frequency, EventFrequency.veryHigh);
      expect(settings.customActions, ['a1', 'a2']);
      expect(settings.customVerites, ['v1']);
    });
  });

  group('SettingsState.setEventEnabled', () {
    test('adds and removes event types from the enabled set', () async {
      final settings = SettingsState();
      await settings.load();

      settings.setEventEnabled(EventType.duel, false);
      expect(settings.enabledEvents.contains(EventType.duel), isFalse);

      settings.setEventEnabled(EventType.duel, true);
      expect(settings.enabledEvents.contains(EventType.duel), isTrue);
    });

    test('persists across a fresh load()', () async {
      final settings = SettingsState();
      await settings.load();
      settings.setEventEnabled(EventType.global, false);
      // Let the fire-and-forget persistence Future complete.
      await Future<void>.delayed(Duration.zero);

      final reloaded = SettingsState();
      await reloaded.load();
      expect(reloaded.enabledEvents.contains(EventType.global), isFalse);
    });

    test('notifies listeners', () async {
      final settings = SettingsState();
      await settings.load();
      var count = 0;
      settings.addListener(() => count++);
      settings.setEventEnabled(EventType.role, false);
      expect(count, 1);
    });
  });

  group('SettingsState.setFrequency', () {
    test('updates and persists the frequency', () async {
      final settings = SettingsState();
      await settings.load();
      settings.setFrequency(EventFrequency.low);
      expect(settings.frequency, EventFrequency.low);
      await Future<void>.delayed(Duration.zero);

      final reloaded = SettingsState();
      await reloaded.load();
      expect(reloaded.frequency, EventFrequency.low);
    });
  });

  group('SettingsState.addCustom / removeCustom', () {
    test('adds an action to customActions and returns true', () async {
      final settings = SettingsState();
      await settings.load();
      final added = settings.addCustom(isAction: true, text: 'Fais 10 pompes');
      expect(added, isTrue);
      expect(settings.customActions, ['Fais 10 pompes']);
      expect(settings.customVerites, isEmpty);
    });

    test('adds a vérité to customVerites and returns true', () async {
      final settings = SettingsState();
      await settings.load();
      final added = settings.addCustom(isAction: false, text: 'Ton secret ?');
      expect(added, isTrue);
      expect(settings.customVerites, ['Ton secret ?']);
      expect(settings.customActions, isEmpty);
    });

    test('rejects new entries once maxCustomEntries is reached', () async {
      final settings = SettingsState();
      await settings.load();
      for (var i = 0; i < SettingsState.maxCustomEntries; i++) {
        expect(settings.addCustom(isAction: true, text: 'entry-$i'), isTrue);
      }
      expect(settings.customActions.length, SettingsState.maxCustomEntries);

      final overflowed = settings.addCustom(isAction: true, text: 'one-too-many');
      expect(overflowed, isFalse);
      expect(settings.customActions.length, SettingsState.maxCustomEntries);
    });

    test('actions and vérités have independent caps', () async {
      final settings = SettingsState();
      await settings.load();
      for (var i = 0; i < SettingsState.maxCustomEntries; i++) {
        settings.addCustom(isAction: true, text: 'a-$i');
      }
      // The action list is full, but the vérité list should still accept
      // entries since the cap is per-category.
      final addedVerite = settings.addCustom(isAction: false, text: 'v-0');
      expect(addedVerite, isTrue);
    });

    test('removeCustom removes the entry at the given index', () async {
      final settings = SettingsState();
      await settings.load();
      settings.addCustom(isAction: true, text: 'keep-me');
      settings.addCustom(isAction: true, text: 'remove-me');
      settings.removeCustom(isAction: true, index: 1);
      expect(settings.customActions, ['keep-me']);
    });

    test('custom entries persist across a fresh load()', () async {
      final settings = SettingsState();
      await settings.load();
      settings.addCustom(isAction: true, text: 'persisted-action');
      settings.addCustom(isAction: false, text: 'persisted-verite');
      await Future<void>.delayed(Duration.zero);

      final reloaded = SettingsState();
      await reloaded.load();
      expect(reloaded.customActions, ['persisted-action']);
      expect(reloaded.customVerites, ['persisted-verite']);
    });
  });
}
