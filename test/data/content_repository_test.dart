import 'package:flutter_test/flutter_test.dart';

import 'package:blackout/data/content_repository.dart';
import 'package:blackout/models/game_enums.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final repository = ContentRepository();

  group('ContentRepository action/vérité decks', () {
    for (final difficulty in Difficulty.values) {
      test('loads a non-empty actions deck for ${difficulty.name}', () async {
        final entries = await repository.loadActions({difficulty});
        expect(entries, isNotEmpty);
        expect(entries.every((e) => e.isNotEmpty), isTrue);
      });

      test('loads a non-empty vérités deck for ${difficulty.name}', () async {
        final entries = await repository.loadVerites({difficulty});
        expect(entries, isNotEmpty);
        expect(entries.every((e) => e.isNotEmpty), isTrue);
      });
    }

    test('loadActions with multiple difficulties concatenates all decks',
        () async {
      final soft = await repository.loadActions({Difficulty.soft});
      final medium = await repository.loadActions({Difficulty.medium});
      final combined =
          await repository.loadActions({Difficulty.soft, Difficulty.medium});
      expect(combined.length, soft.length + medium.length);
    });

    test('loadActions with an empty set returns an empty list', () async {
      final entries = await repository.loadActions({});
      expect(entries, isEmpty);
    });
  });

  group('ContentRepository event decks', () {
    for (final type in EventType.values) {
      test('loads a non-empty deck for ${type.name} '
          '(regression guard for the original app\'s malformed duel.json)',
          () async {
        final entries = await repository.loadEvent(type);
        expect(entries, isNotEmpty);
        expect(entries.every((e) => e.isNotEmpty), isTrue);
      });
    }
  });

  group('ContentRepository transition decks', () {
    test('loads a non-empty male transitions deck '
        '(regression guard for the original app\'s malformed '
        'transitionHomme.json)', () async {
      final entries = await repository.loadTransitionsMale();
      expect(entries, isNotEmpty);
    });

    test('loads a non-empty female transitions deck', () async {
      final entries = await repository.loadTransitionsFemale();
      expect(entries, isNotEmpty);
    });
  });
}
