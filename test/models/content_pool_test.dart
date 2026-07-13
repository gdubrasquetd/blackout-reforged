import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:blackout/models/content_pool.dart';

void main() {
  group('ContentPool', () {
    test('isEmpty reflects whether the pool has any entries', () {
      expect(ContentPool([]).isEmpty, isTrue);
      expect(ContentPool(['a']).isEmpty, isFalse);
    });

    test('draw() throws StateError on an empty pool', () {
      final pool = ContentPool([]);
      expect(() => pool.draw(), throwsStateError);
    });

    test('draw() returns every entry exactly once before repeating', () {
      final entries = ['a', 'b', 'c', 'd', 'e'];
      final pool = ContentPool(entries, random: Random(42));

      final drawn = List.generate(entries.length, (_) => pool.draw());

      expect(drawn.toSet(), equals(entries.toSet()));
      expect(drawn.length, entries.length);
    });

    test('justExhausted is false during a normal draw and true on reshuffle',
        () {
      final pool = ContentPool(['a', 'b'], random: Random(1));

      pool.draw();
      expect(pool.justExhausted, isFalse);

      // Second draw empties the bag; justExhausted only flips on refill.
      pool.draw();

      // Third draw refills the bag from scratch -> justExhausted becomes true.
      pool.draw();
      expect(pool.justExhausted, isTrue);
    });

    test('reshuffles and keeps drawing after the pool is exhausted', () {
      final pool = ContentPool(['a', 'b'], random: Random(7));
      final drawn = List.generate(10, (_) => pool.draw());

      expect(drawn.length, 10);
      for (final entry in drawn) {
        expect(['a', 'b'], contains(entry));
      }
    });

    test('addCustomEntries makes new entries immediately drawable and '
        'keeps them across reshuffles', () {
      final pool = ContentPool(['a'], random: Random(3));
      pool.addCustomEntries(['custom']);

      final firstCycle = {pool.draw(), pool.draw()};
      expect(firstCycle, equals({'a', 'custom'}));

      // Custom entries persist into the next shuffle cycle too.
      final secondCycle = {pool.draw(), pool.draw()};
      expect(secondCycle, equals({'a', 'custom'}));
    });

    test('reset() clears drawn history and justExhausted flag', () {
      final pool = ContentPool(['a', 'b'], random: Random(5));
      pool.draw();
      pool.draw();
      pool.draw(); // triggers a reshuffle -> justExhausted = true
      expect(pool.justExhausted, isTrue);

      pool.reset();
      expect(pool.justExhausted, isFalse);

      // After reset, a full fresh cycle is available again.
      final drawn = {pool.draw(), pool.draw()};
      expect(drawn, equals({'a', 'b'}));
    });
  });
}
