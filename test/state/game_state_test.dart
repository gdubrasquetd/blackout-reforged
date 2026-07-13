import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:blackout/data/content_repository.dart';
import 'package:blackout/models/game_enums.dart';
import 'package:blackout/models/player.dart';
import 'package:blackout/state/game_state.dart';

import '../helpers/fake_content_repository.dart';

const alice = Player(name: 'Alice', gender: Gender.female);
const bob = Player(name: 'Bob', gender: Gender.male);
const carla = Player(name: 'Carla', gender: Gender.female);
const dan = Player(name: 'Dan', gender: Gender.male);

Future<GameState> readyGame({
  List<Player> players = const [alice, bob, carla, dan],
  Set<Difficulty> difficulties = const {Difficulty.soft},
  List<String> customActions = const [],
  List<String> customVerites = const [],
  int seed = 1,
  FakeContentRepository? repository,
}) async {
  final state = GameState(
    repository: repository ?? FakeContentRepository(),
    random: Random(seed),
  );
  await state.startNewGame(
    players: players,
    difficulties: difficulties,
    customActions: customActions,
    customVerites: customVerites,
  );
  return state;
}

void main() {
  group('GameState.startNewGame', () {
    test('is not ready before startNewGame is called', () {
      final state = GameState(repository: FakeContentRepository());
      expect(state.isReady, isFalse);
    });

    test('becomes ready and stores the player roster', () async {
      final state = await readyGame();
      expect(state.isReady, isTrue);
      expect(state.players, [alice, bob, carla, dan]);
    });

    test('loads only the requested difficulty decks', () async {
      final repo = FakeContentRepository();
      final state = await readyGame(
        difficulties: {Difficulty.hard},
        repository: repo,
      );
      state.nextTurn();
      final drawn = <String>{};
      for (var i = 0; i < 2; i++) {
        drawn.add(state.drawAction());
      }
      for (final card in drawn) {
        expect(card, contains('hard'));
      }
    });

    test('merges multiple selected difficulties', () async {
      final state = await readyGame(
        difficulties: {Difficulty.soft, Difficulty.medium},
      );
      state.nextTurn();
      final drawn = List.generate(4, (_) => state.drawAction());
      expect(drawn.any((c) => c.contains('soft')), isTrue);
      expect(drawn.any((c) => c.contains('medium')), isTrue);
    });

    test('folds in custom actions and vérités', () async {
      final state = await readyGame(
        customActions: ['ma-custom-action'],
        customVerites: ['ma-custom-verite'],
      );
      state.nextTurn();
      final actions = List.generate(3, (_) => state.drawAction());
      expect(actions, contains('ma-custom-action'));
    });

    test('resets turn/event bookkeeping when starting a second game',
        () async {
      final state = await readyGame();
      // Advance turns to build up passed-player history.
      state.nextTurn();
      state.nextTurn();

      await state.startNewGame(
        players: const [alice, bob],
        difficulties: const {Difficulty.soft},
        customActions: const [],
        customVerites: const [],
      );

      expect(state.currentPlayer, isNull);
      expect(state.players, [alice, bob]);
    });
  });

  group('GameState.nextTurn', () {
    test('sets currentPlayer to one of the roster', () async {
      final state = await readyGame();
      state.nextTurn();
      expect(state.players, contains(state.currentPlayer));
    });

    test('never repeats the same player twice in a row (2+ players)',
        () async {
      final state = await readyGame(seed: 99);
      Player? previous;
      for (var i = 0; i < 30; i++) {
        state.nextTurn();
        if (previous != null) {
          expect(state.currentPlayer, isNot(equals(previous)));
        }
        previous = state.currentPlayer;
      }
    });

    test('cycles through every player before anyone repeats', () async {
      final state = await readyGame(seed: 5);
      final seenInCycle = <Player>{};
      for (var i = 0; i < 4; i++) {
        state.nextTurn();
        expect(seenInCycle, isNot(contains(state.currentPlayer)));
        seenInCycle.add(state.currentPlayer!);
      }
      expect(seenInCycle, {alice, bob, carla, dan});
    });

    test('sets a gendered transition line matching the picked player',
        () async {
      final state = await readyGame(
        repository: FakeContentRepository(
          transitionsMale: ['H-line'],
          transitionsFemale: ['F-line'],
        ),
      );
      for (var i = 0; i < 10; i++) {
        state.nextTurn();
        final expected =
            state.currentPlayer!.gender == Gender.male ? 'H-line' : 'F-line';
        expect(state.currentTransitionText, expected);
      }
    });

    test('notifies listeners on every turn', () async {
      final state = await readyGame();
      var notifications = 0;
      state.addListener(() => notifications++);
      state.nextTurn();
      state.nextTurn();
      expect(notifications, 2);
    });

    test('works correctly with exactly 2 players (strict alternation)',
        () async {
      final state = await readyGame(players: const [alice, bob]);
      state.nextTurn();
      final first = state.currentPlayer;
      state.nextTurn();
      final second = state.currentPlayer;
      state.nextTurn();
      final third = state.currentPlayer;

      expect(second, isNot(equals(first)));
      expect(third, isNot(equals(second)));
    });
  });

  group('GameState.drawAction / drawVerite', () {
    test('drawAction substitutes the random placeholder with another player',
        () async {
      final state = await readyGame(
        repository: FakeContentRepository(
          actionsByDifficulty: {
            Difficulty.soft: ['Fais un bisou à %s'],
            Difficulty.medium: ['m'],
            Difficulty.hard: ['h'],
          },
        ),
      );
      state.nextTurn();
      final text = state.drawAction();
      expect(text, startsWith('Fais un bisou à '));
      final namedPlayer = text.replaceFirst('Fais un bisou à ', '');
      expect(state.players.map((p) => p.name), contains(namedPlayer));
      expect(namedPlayer, isNot(state.currentPlayer!.name));
    });

    test('drawVerite substitutes gendered placeholders correctly', () async {
      final state = await readyGame(
        players: const [alice, bob],
        repository: FakeContentRepository(
          veritesByDifficulty: {
            Difficulty.soft: ['%4\$s est un homme, %5\$s est une femme'],
            Difficulty.medium: ['m'],
            Difficulty.hard: ['h'],
          },
        ),
      );
      state.nextTurn();
      final text = state.drawVerite();
      expect(text, 'Bob est un homme, Alice est une femme');
    });

    test('opposite/same gender placeholders reflect the current player',
        () async {
      // Alice+Carla are female, Bob is the only male: this makes the
      // expected opposite/same names unambiguous for every possible
      // current player.
      final state = await readyGame(
        players: const [alice, bob, carla],
        repository: FakeContentRepository(
          actionsByDifficulty: {
            Difficulty.soft: ['opposé:%2\$s meme:%3\$s'],
            Difficulty.medium: ['m'],
            Difficulty.hard: ['h'],
          },
        ),
      );
      // Force enough turns to observe both a male and a female "current player".
      for (var i = 0; i < 10; i++) {
        state.nextTurn();
        final text = state.drawAction();
        final current = state.currentPlayer!;
        final match = RegExp(r'opposé:(.+) meme:(.+)').firstMatch(text)!;
        final opposite = match.group(1);
        final same = match.group(2);
        if (current.gender == Gender.female) {
          // Opposite of a female is the only male: Bob.
          expect(opposite, 'Bob');
          // Same as a female excluding self is the other female.
          expect(same, current.name == 'Alice' ? 'Carla' : 'Alice');
        } else {
          // Opposite of the only male (Bob) is one of the two females.
          expect(['Alice', 'Carla'], contains(opposite));
          // No other male exists, so "same" falls back to a random other
          // player (still one of Alice/Carla).
          expect(['Alice', 'Carla'], contains(same));
        }
      }
    });

    test('falls back gracefully when no player of the needed gender exists',
        () async {
      final state = await readyGame(
        players: const [alice, carla], // all female
        repository: FakeContentRepository(
          actionsByDifficulty: {
            Difficulty.soft: ['boy:%4\$s'],
            Difficulty.medium: ['m'],
            Difficulty.hard: ['h'],
          },
        ),
      );
      state.nextTurn();
      final text = state.drawAction();
      // No boy exists, so it falls back to a random other player instead of
      // crashing.
      expect(text, startsWith('boy:'));
      final name = text.replaceFirst('boy:', '');
      expect(state.players.map((p) => p.name), contains(name));
    });
  });

  group('GameState.maybeTriggerEvent', () {
    test('never triggers before 3 turns have passed since the last event',
        () async {
      final state = await readyGame(seed: 1);
      state.nextTurn();
      for (var i = 0; i < 3; i++) {
        final result = state.maybeTriggerEvent(
          frequency: EventFrequency.veryHigh,
          enabledTypes: EventType.values.toSet(),
        );
        expect(result, isNull);
      }
    });

    test('never triggers when frequency is "none" (0%)', () async {
      final state = await readyGame(seed: 2);
      state.nextTurn();
      for (var i = 0; i < 20; i++) {
        final result = state.maybeTriggerEvent(
          frequency: EventFrequency.none,
          enabledTypes: EventType.values.toSet(),
        );
        expect(result, isNull);
      }
    });

    test('never triggers when no event types are enabled', () async {
      final state = await readyGame(seed: 3);
      state.nextTurn();
      for (var i = 0; i < 20; i++) {
        final result = state.maybeTriggerEvent(
          frequency: EventFrequency.veryHigh,
          enabledTypes: {},
        );
        expect(result, isNull);
      }
    });

    test('eventually triggers at very-high frequency once cooldown passes',
        () async {
      final state = await readyGame(seed: 42);
      state.nextTurn();
      EventType? triggered;
      for (var i = 0; i < 50 && triggered == null; i++) {
        triggered = state.maybeTriggerEvent(
          frequency: EventFrequency.veryHigh,
          enabledTypes: EventType.values.toSet(),
        );
      }
      expect(triggered, isNotNull);
      expect(EventType.values, contains(triggered));
    });

    test('only returns a type from the enabled set', () async {
      final state = await readyGame(seed: 7);
      state.nextTurn();
      EventType? triggered;
      for (var i = 0; i < 80 && triggered == null; i++) {
        triggered = state.maybeTriggerEvent(
          frequency: EventFrequency.veryHigh,
          enabledTypes: {EventType.duel},
        );
      }
      expect(triggered, EventType.duel);
    });
  });

  group('GameState.drawEventCard', () {
    test('duel substitutes two distinct player names', () async {
      final state = await readyGame(
        players: const [alice, bob, carla],
        repository: FakeContentRepository(
          eventsByType: {
            for (final t in EventType.values) t: ['t'],
            EventType.duel: ['%s contre %2\$s'],
          },
        ),
      );
      state.nextTurn();
      final text = state.drawEventCard(EventType.duel);
      final match = RegExp(r'^(.+) contre (.+)$').firstMatch(text)!;
      final p1 = match.group(1)!;
      final p2 = match.group(2)!;
      expect(p1, isNot(p2));
      expect(state.players.map((p) => p.name), contains(p1));
      expect(state.players.map((p) => p.name), contains(p2));
    });

    test('global substitutes a quoted random letter', () async {
      final state = await readyGame(
        repository: FakeContentRepository(
          eventsByType: {
            for (final t in EventType.values) t: ['t'],
            EventType.global: ['Tous ceux qui ont %s boivent'],
          },
        ),
      );
      state.nextTurn();
      final text = state.drawEventCard(EventType.global);
      expect(RegExp(r'^Tous ceux qui ont "[AEOIMLNS]" boivent$').hasMatch(text),
          isTrue);
    });

    test('dilem/minijeu/role use the current player\'s gendered context',
        () async {
      final state = await readyGame(
        players: const [alice, bob],
        repository: FakeContentRepository(
          eventsByType: {
            for (final t in EventType.values) t: ['t'],
            EventType.role: ['%4\$s et %5\$s'],
          },
        ),
      );
      state.nextTurn();
      final text = state.drawEventCard(EventType.role);
      expect(text, 'Bob et Alice');
    });

    test('marks an event pool unavailable once fully cycled', () async {
      final state = await readyGame(
        repository: FakeContentRepository(
          eventsByType: {
            for (final t in EventType.values) t: ['t'],
            EventType.dilem: ['only-card'],
          },
        ),
      );
      state.nextTurn();
      // Draw the single dilem card twice: 2nd draw triggers a reshuffle,
      // which is what marks the pool "exhausted" internally. This should
      // not throw and should keep returning the same content.
      final first = state.drawEventCard(EventType.dilem);
      final second = state.drawEventCard(EventType.dilem);
      expect(first, 'only-card');
      expect(second, 'only-card');
    });
  });

  group('GameState error handling', () {
    test('nextTurn throws a clear StateError before startNewGame is called',
        () {
      final state = GameState(repository: FakeContentRepository());
      expect(() => state.nextTurn(), throwsStateError);
    });

    test('drawAction/drawVerite/drawEventCard throw before startNewGame', () {
      final state = GameState(repository: FakeContentRepository());
      expect(() => state.drawAction(), throwsStateError);
      expect(() => state.drawVerite(), throwsStateError);
      expect(() => state.drawEventCard(EventType.duel), throwsStateError);
    });

    test(
        'a failing deck load leaves a previously-started game fully intact '
        '(no partial state corruption)', () async {
      final repo = _FlakyRepository();
      final state = GameState(repository: repo, random: Random(1));
      await state.startNewGame(
        players: const [alice, bob, carla, dan],
        difficulties: {Difficulty.soft},
        customActions: const [],
        customVerites: const [],
      );
      state.nextTurn();
      final playerBefore = state.currentPlayer;

      // Fail on the very last deck the reload would swap in, so a partial
      // swap would be observable if one occurred.
      repo.shouldFail = true;
      await expectLater(
        state.startNewGame(
          players: const [alice, bob],
          difficulties: {Difficulty.soft},
          customActions: const [],
          customVerites: const [],
        ),
        throwsA(isA<Exception>()),
      );

      // The old roster/turn state must still be exactly as it was -- not
      // half-overwritten by the failed reload.
      expect(state.isReady, isTrue);
      expect(state.players, [alice, bob, carla, dan]);
      expect(state.currentPlayer, playerBefore);
      // And the game must still be fully usable.
      expect(() => state.drawAction(), returnsNormally);
    });
  });
}

/// Succeeds normally until [shouldFail] is flipped, at which point the very
/// last deck [GameState.startNewGame] awaits starts throwing.
class _FlakyRepository implements ContentRepository {
  bool shouldFail = false;

  @override
  Future<List<String>> loadActions(Set<Difficulty> difficulties) async =>
      ['a'];

  @override
  Future<List<String>> loadVerites(Set<Difficulty> difficulties) async =>
      ['v'];

  @override
  Future<List<String>> loadEvent(EventType type) async => ['e'];

  @override
  Future<List<String>> loadTransitionsMale() async => ['h'];

  @override
  Future<List<String>> loadTransitionsFemale() async {
    if (shouldFail) throw Exception('boom');
    return ['f'];
  }
}
