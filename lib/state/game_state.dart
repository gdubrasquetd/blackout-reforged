import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/content_repository.dart';
import '../models/card_text.dart';
import '../models/content_pool.dart';
import '../models/game_enums.dart';
import '../models/player.dart';

enum GamePhase { setup, choice, action, verite, event, transition }

/// Holds all state for the game currently in progress: players, turn order,
/// card decks and the special-event trigger logic.
///
/// This replaces the original app's approach of using `static` mutable
/// fields on `Game`/`Player`/`HomePage` as ad-hoc global state -- which made
/// at most one game instance possible, broke on process death, and could
/// not be unit tested. This is a single ChangeNotifier owned by the widget
/// tree via Provider.
class GameState extends ChangeNotifier {
  final ContentRepository _repository;
  final Random _random;

  GameState({ContentRepository? repository, Random? random})
      : _repository = repository ?? ContentRepository(),
        _random = random ?? Random();

  List<Player> players = [];

  Player? currentPlayer;
  Player? _lastPlayer;
  final List<Player> _passedPlayers = [];

  String? currentTransitionText;

  ContentPool? _actions;
  ContentPool? _verites;
  final Map<EventType, ContentPool> _eventPools = {};
  ContentPool? _transitionsMale;
  ContentPool? _transitionsFemale;

  final Map<EventType, bool> _eventAvailable = {
    for (final t in EventType.values) t: true,
  };
  int _turnsSinceEvent = 0;

  bool get isReady => _actions != null;

  /// Loads every deck needed for a game and only then swaps them into place.
  ///
  /// Everything is built into locals first and assigned atomically at the
  /// end. If any deck fails to load (see [ContentRepository]), this throws
  /// and the previous game's state -- if any -- is left completely intact
  /// instead of being left half-swapped (which used to be able to leave
  /// [_transitionsMale]/[_transitionsFemale] null while [isReady] already
  /// read true, crashing the next [nextTurn] call with a null-check error
  /// instead of a catchable, meaningful exception).
  Future<void> startNewGame({
    required List<Player> players,
    required Set<Difficulty> difficulties,
    required List<String> customActions,
    required List<String> customVerites,
  }) async {
    final actionEntries = await _repository.loadActions(difficulties);
    final veriteEntries = await _repository.loadVerites(difficulties);
    final newEventPools = <EventType, ContentPool>{};
    for (final type in EventType.values) {
      newEventPools[type] =
          ContentPool(await _repository.loadEvent(type), random: _random);
    }
    final newTransitionsMale =
        ContentPool(await _repository.loadTransitionsMale(), random: _random);
    final newTransitionsFemale = ContentPool(
        await _repository.loadTransitionsFemale(),
        random: _random);

    this.players = List.of(players);
    currentPlayer = null;
    _lastPlayer = null;
    _passedPlayers.clear();
    _turnsSinceEvent = 0;
    for (final t in EventType.values) {
      _eventAvailable[t] = true;
    }
    _actions = ContentPool(actionEntries, random: _random)
      ..addCustomEntries(customActions);
    _verites = ContentPool(veriteEntries, random: _random)
      ..addCustomEntries(customVerites);
    _eventPools
      ..clear()
      ..addAll(newEventPools);
    _transitionsMale = newTransitionsMale;
    _transitionsFemale = newTransitionsFemale;

    notifyListeners();
  }

  void _requireReady() {
    if (!isReady) {
      throw StateError(
          'GameState method called before startNewGame() completed');
    }
  }

  /// Picks the next player, avoiding immediate repeats and avoiding any
  /// repeat at all until everyone has had a turn (ported from the
  /// original's `passedPlayer`/`lastPlayer` bookkeeping in `Game`).
  void nextTurn() {
    _requireReady();
    final candidates = List<Player>.from(players);
    if (players.length == _passedPlayers.length) {
      candidates.remove(_lastPlayer);
      _passedPlayers.clear();
    } else {
      for (final p in _passedPlayers) {
        candidates.remove(p);
      }
    }
    final pick = candidates[_random.nextInt(candidates.length)];
    _lastPlayer = pick;
    _passedPlayers.add(pick);
    currentPlayer = pick;

    final pool =
        pick.gender == Gender.male ? _transitionsMale! : _transitionsFemale!;
    currentTransitionText = pool.draw();

    notifyListeners();
  }

  Player _pickAnyPlayer({Player? exclude}) {
    final candidates = List<Player>.from(players);
    if (exclude != null) candidates.remove(exclude);
    if (candidates.isEmpty) candidates.addAll(players);
    return candidates[_random.nextInt(candidates.length)];
  }

  String _randomOtherName(Player current) {
    final others = players.where((p) => p != current).toList();
    if (others.isEmpty) return 'quelqu\'un';
    return others[_random.nextInt(others.length)].name;
  }

  String _genderName(Player current, Gender gender) {
    final matches = players
        .where((p) => p.gender == gender && p != current)
        .toList();
    if (matches.isEmpty) return _randomOtherName(current);
    return matches[_random.nextInt(matches.length)].name;
  }

  /// A random player of [gender] among *everyone*, including the current
  /// player -- unlike [_genderName], "a boy"/"a girl" placeholders aren't
  /// relative to whoever's turn it is.
  String _anyGenderName(Gender gender) {
    final matches = players.where((p) => p.gender == gender).toList();
    if (matches.isEmpty) return _randomOtherName(currentPlayer!);
    return matches[_random.nextInt(matches.length)].name;
  }

  String _formatForCurrentPlayer(String template) {
    final current = currentPlayer!;
    final excludingBoy = _genderName(current, Gender.male);
    final excludingGirl = _genderName(current, Gender.female);
    final opposite = current.gender == Gender.male ? excludingGirl : excludingBoy;
    final same = current.gender == Gender.male ? excludingBoy : excludingGirl;
    return formatCard(
      template,
      random: _randomOtherName(current),
      opposite: opposite,
      same: same,
      boy: _anyGenderName(Gender.male),
      girl: _anyGenderName(Gender.female),
    );
  }

  String drawAction() {
    _requireReady();
    return _formatForCurrentPlayer(_actions!.draw());
  }

  String drawVerite() {
    _requireReady();
    return _formatForCurrentPlayer(_verites!.draw());
  }

  /// Rolls whether a special event should interrupt the next turn, matching
  /// the original's probability/cooldown rules: an event needs at least 3
  /// turns since the last one, a favorable roll against [frequency], and at
  /// least one enabled event type. Returns the chosen event type, or null if
  /// no event should fire.
  EventType? maybeTriggerEvent({
    required EventFrequency frequency,
    required Set<EventType> enabledTypes,
  }) {
    final roll = _random.nextInt(100);
    if (roll < frequency.probabilityPercent &&
        _turnsSinceEvent > 2 &&
        enabledTypes.isNotEmpty) {
      _turnsSinceEvent = 1;
      var candidates =
          enabledTypes.where((t) => _eventAvailable[t] == true).toList();
      if (candidates.isEmpty) {
        for (final t in EventType.values) {
          _eventAvailable[t] = true;
        }
        candidates = enabledTypes.toList();
      }
      return candidates[_random.nextInt(candidates.length)];
    }
    _turnsSinceEvent++;
    return null;
  }

  String drawEventCard(EventType type) {
    _requireReady();
    final pool = _eventPools[type]!;

    switch (type) {
      case EventType.duel:
        final p1 = _pickAnyPlayer();
        final p2 = _pickAnyPlayer(exclude: p1);
        final text = pool.draw();
        if (pool.justExhausted) _eventAvailable[type] = false;
        return formatCard(text,
            random: p1.name, opposite: p2.name, same: '', boy: '', girl: '');

      case EventType.global:
        const letters = ['A', 'E', 'O', 'I', 'M', 'L', 'N', 'S'];
        final letter = '"${letters[_random.nextInt(letters.length)]}"';
        final text = pool.draw();
        if (pool.justExhausted) _eventAvailable[type] = false;
        return formatCard(text,
            random: letter, opposite: '', same: '', boy: '', girl: '');

      case EventType.dilem:
      case EventType.minijeu:
      case EventType.role:
        final text = pool.draw();
        if (pool.justExhausted) _eventAvailable[type] = false;
        return _formatForCurrentPlayer(text);
    }
  }
}
