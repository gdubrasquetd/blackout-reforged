import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/game_enums.dart';
import 'content_load_exception.dart';

/// Loads the JSON card decks bundled as Flutter assets. All decks were
/// recovered from the original app's shipped assets; two of them
/// (`duel.json`, `transitionHomme.json`) had a missing comma that silently
/// broke JSON parsing in production (the exception was swallowed), so the
/// Duel event and half the male transition lines were effectively dead in
/// the last published build. Both are fixed in the bundled copies.
class ContentRepository {
  static const _difficultyFiles = {
    Difficulty.soft: ('actionSoft.json', 'veriteSoft.json'),
    Difficulty.medium: ('actionMedium.json', 'veriteMedium.json'),
    Difficulty.hard: ('actionHard.json', 'veriteHard.json'),
  };

  /// Reads and parses one content deck. Never throws a raw
  /// [FormatException]/[FlutterError] -- any read or parse failure is
  /// wrapped in a [ContentLoadException] so callers can catch one type and
  /// show the player a clear "couldn't load the game" message instead of
  /// crashing on whatever happens to try drawing from the resulting empty
  /// deck.
  Future<List<String>> _loadList(String fileName, String key) async {
    final assetPath = 'assets/content/$fileName';
    try {
      final raw = await rootBundle.loadString(assetPath);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final list = (json[key] as List).cast<String>();
      if (list.isEmpty) {
        throw const FormatException('deck is empty');
      }
      return list;
    } on ContentLoadException {
      rethrow;
    } catch (e) {
      throw ContentLoadException(assetPath, e);
    }
  }

  Future<List<String>> loadActions(Set<Difficulty> difficulties) async {
    final result = <String>[];
    for (final d in difficulties) {
      final (actionFile, _) = _difficultyFiles[d]!;
      result.addAll(await _loadList(actionFile, 'actions'));
    }
    return result;
  }

  Future<List<String>> loadVerites(Set<Difficulty> difficulties) async {
    final result = <String>[];
    for (final d in difficulties) {
      final (_, veriteFile) = _difficultyFiles[d]!;
      result.addAll(await _loadList(veriteFile, 'verites'));
    }
    return result;
  }

  Future<List<String>> loadEvent(EventType type) {
    return switch (type) {
      EventType.duel => _loadList('duel.json', 'duel'),
      EventType.dilem => _loadList('dilem.json', 'dilem'),
      EventType.global => _loadList('global.json', 'global'),
      EventType.minijeu => _loadList('miniJeu.json', 'minijeu'),
      EventType.role => _loadList('role.json', 'role'),
    };
  }

  Future<List<String>> loadTransitionsMale() =>
      _loadList('transitionHomme.json', 'transitionHomme');

  Future<List<String>> loadTransitionsFemale() =>
      _loadList('transitionFemme.json', 'transitionFemme');
}
