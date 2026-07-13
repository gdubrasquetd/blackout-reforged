import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../error_reporting.dart';
import '../models/game_enums.dart';

/// Persists user settings and personalized content across app restarts.
///
/// The original app kept all of this (event toggles, frequency, custom
/// questions/dares) in static in-memory fields only -- everything reset the
/// moment the process was killed. This is the fix: real persistence via
/// SharedPreferences.
class SettingsState extends ChangeNotifier {
  static const _keyEnabledEvents = 'enabled_events';
  static const _keyFrequency = 'event_frequency';
  static const _keyCustomActions = 'custom_actions';
  static const _keyCustomVerites = 'custom_verites';

  Set<EventType> enabledEvents = EventType.values.toSet();
  EventFrequency frequency = EventFrequency.normal;
  List<String> customActions = [];
  List<String> customVerites = [];

  bool _loaded = false;
  bool get loaded => _loaded;

  /// Restores settings from disk. If anything goes wrong -- corrupted
  /// prefs, an enum value from a future app version that no longer exists,
  /// a platform channel failure -- this falls back to the in-memory
  /// defaults instead of leaving the app stuck on an unfulfilled Future
  /// (nothing in the UI awaits this call; it's fired once from `main.dart`
  /// and observed only through [loaded]/[notifyListeners]).
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final storedEvents = prefs.getStringList(_keyEnabledEvents);
      if (storedEvents != null) {
        enabledEvents = storedEvents
            .map((name) => EventType.values.byName(name))
            .toSet();
      }

      final storedFrequency = prefs.getString(_keyFrequency);
      if (storedFrequency != null) {
        frequency = EventFrequency.values.byName(storedFrequency);
      }

      customActions = _decodeList(prefs.getString(_keyCustomActions));
      customVerites = _decodeList(prefs.getString(_keyCustomVerites));
    } catch (error, stackTrace) {
      reportError(error, stackTrace, context: 'SettingsState.load');
      // Keep whatever had already been parsed and fall back to defaults
      // for the rest; a broken settings read must never block play.
    }
    _loaded = true;
    notifyListeners();
  }

  List<String> _decodeList(String? raw) {
    if (raw == null) return [];
    return (jsonDecode(raw) as List).cast<String>();
  }

  /// Persists the current settings. Called fire-and-forget from every
  /// mutator below (the in-memory state and UI are already updated by the
  /// time this runs), so failures are caught and reported here rather than
  /// becoming an unhandled `Future` rejection -- a full disk or a flaky
  /// platform channel shouldn't crash the app over a settings save.
  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
          _keyEnabledEvents, enabledEvents.map((e) => e.name).toList());
      await prefs.setString(_keyFrequency, frequency.name);
      await prefs.setString(_keyCustomActions, jsonEncode(customActions));
      await prefs.setString(_keyCustomVerites, jsonEncode(customVerites));
    } catch (error, stackTrace) {
      reportError(error, stackTrace, context: 'SettingsState._persist');
    }
  }

  void setEventEnabled(EventType type, bool enabled) {
    if (enabled) {
      enabledEvents.add(type);
    } else {
      enabledEvents.remove(type);
    }
    notifyListeners();
    _persist();
  }

  void setFrequency(EventFrequency value) {
    frequency = value;
    notifyListeners();
    _persist();
  }

  static const maxCustomEntries = 20;

  bool addCustom({required bool isAction, required String text}) {
    final list = isAction ? customActions : customVerites;
    if (list.length >= maxCustomEntries) return false;
    list.add(text);
    notifyListeners();
    _persist();
    return true;
  }

  void removeCustom({required bool isAction, required int index}) {
    final list = isAction ? customActions : customVerites;
    list.removeAt(index);
    notifyListeners();
    _persist();
  }
}
