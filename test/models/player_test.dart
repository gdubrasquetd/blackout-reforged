import 'package:flutter_test/flutter_test.dart';

import 'package:blackout/models/player.dart';

void main() {
  group('Player', () {
    test('equality is based on name and gender', () {
      const a = Player(name: 'Alice', gender: Gender.female);
      const b = Player(name: 'Alice', gender: Gender.female);
      const c = Player(name: 'Alice', gender: Gender.male);
      const d = Player(name: 'Bob', gender: Gender.female);

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a, isNot(equals(d)));
    });

    test('equal players share the same hashCode', () {
      const a = Player(name: 'Alice', gender: Gender.female);
      const b = Player(name: 'Alice', gender: Gender.female);
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString returns the player name', () {
      const p = Player(name: 'Bob', gender: Gender.male);
      expect(p.toString(), 'Bob');
    });

    test('copyWith overrides only the given fields', () {
      const p = Player(name: 'Alice', gender: Gender.female);
      final renamed = p.copyWith(name: 'Alicia');
      final regendered = p.copyWith(gender: Gender.male);
      final untouched = p.copyWith();

      expect(renamed.name, 'Alicia');
      expect(renamed.gender, Gender.female);
      expect(regendered.name, 'Alice');
      expect(regendered.gender, Gender.male);
      expect(untouched, equals(p));
    });

    test('is not equal to a non-Player object', () {
      const p = Player(name: 'Alice', gender: Gender.female);
      // ignore: unrelated_type_equality_checks
      expect(p == 'Alice', isFalse);
    });
  });
}
