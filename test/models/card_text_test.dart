import 'package:flutter_test/flutter_test.dart';

import 'package:blackout/models/card_text.dart';

void main() {
  group('formatCard', () {
    const args = (
      random: 'Alice',
      opposite: 'Bob',
      same: 'Carla',
      boy: 'Dan',
      girl: 'Eve',
    );

    String format(String template) => formatCard(
          template,
          random: args.random,
          opposite: args.opposite,
          same: args.same,
          boy: args.boy,
          girl: args.girl,
        );

    test('%s substitutes the random player', () {
      expect(format('Regarde %s'), 'Regarde Alice');
    });

    test('%2\$s substitutes the opposite-gender player', () {
      expect(format('Embrasse %2\$s'), 'Embrasse Bob');
    });

    test('%3\$s substitutes the same-gender player', () {
      expect(format('Avec %3\$s'), 'Avec Carla');
    });

    test('%4\$s substitutes a boy and %5\$s substitutes a girl', () {
      expect(format('%4\$s et %5\$s'), 'Dan et Eve');
    });

    test('handles multiple placeholders in one template', () {
      expect(
        format('%s doit embrasser %2\$s devant %4\$s et %5\$s'),
        'Alice doit embrasser Bob devant Dan et Eve',
      );
    });

    test('leaves text with no placeholders untouched', () {
      expect(format('Bois un verre.'), 'Bois un verre.');
    });

    test('leaves a trailing lone % character untouched', () {
      expect(format('100%'), '100%');
    });

    test('leaves an out-of-range %N\$s index untouched instead of crashing',
        () {
      // %9$s is out of range for the 5 positional args. Custom cards are
      // free-typed by the host in PersonalizeScreen, so a malformed index
      // must never throw a RangeError when the card is later drawn.
      expect(format('Vérité ou %9\$s'), 'Vérité ou %9\$s');
    });

    test('plain "%" followed by non-digit/non-s text passes through', () {
      expect(format('50% de chance'), '50% de chance');
    });

    test('repeated placeholders all get substituted', () {
      expect(format('%s, %s, %s !'), 'Alice, Alice, Alice !');
    });

    test('empty template returns empty string', () {
      expect(format(''), '');
    });
  });
}
