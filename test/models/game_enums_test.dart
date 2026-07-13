import 'package:flutter_test/flutter_test.dart';

import 'package:blackout/models/game_enums.dart';

void main() {
  group('EventType', () {
    test('labels match the original app\'s on-screen text', () {
      expect(EventType.duel.label, 'Duel');
      expect(EventType.dilem.label, 'Dilemme');
      expect(EventType.global.label, 'Tournée');
      expect(EventType.minijeu.label, 'Mini-jeu');
      expect(EventType.role.label, 'Pouvoir');
    });

    test('every EventType has a distinct transition GIF asset', () {
      final assets = EventType.values.map((e) => e.transitionAsset).toSet();
      expect(assets.length, EventType.values.length);
      for (final asset in assets) {
        expect(asset, startsWith('assets/images/'));
        expect(asset, endsWith('.gif'));
      }
    });

    test('every EventType has a distinct banner asset', () {
      final assets = EventType.values.map((e) => e.bannerAsset).toSet();
      expect(assets.length, EventType.values.length);
      for (final asset in assets) {
        expect(asset, startsWith('assets/images/'));
        expect(asset, endsWith('.png'));
      }
    });

    test('has exactly the 5 expected event types', () {
      expect(
        EventType.values,
        containsAll([
          EventType.duel,
          EventType.dilem,
          EventType.global,
          EventType.minijeu,
          EventType.role,
        ]),
      );
      expect(EventType.values.length, 5);
    });
  });

  group('EventFrequency', () {
    test('probability percentages increase monotonically', () {
      final percentages =
          EventFrequency.values.map((f) => f.probabilityPercent).toList();
      for (var i = 1; i < percentages.length; i++) {
        expect(percentages[i], greaterThan(percentages[i - 1]));
      }
    });

    test('none means a 0% trigger chance', () {
      expect(EventFrequency.none.probabilityPercent, 0);
    });

    test('labels match the original app\'s slider text', () {
      expect(EventFrequency.none.label, 'Aucun');
      expect(EventFrequency.low.label, 'Faible');
      expect(EventFrequency.normal.label, 'Normal');
      expect(EventFrequency.high.label, 'Fréquent');
      expect(EventFrequency.veryHigh.label, 'Très fréquent');
    });
  });

  group('Difficulty', () {
    test('has exactly soft, medium and hard', () {
      expect(Difficulty.values,
          containsAll([Difficulty.soft, Difficulty.medium, Difficulty.hard]));
      expect(Difficulty.values.length, 3);
    });
  });
}
