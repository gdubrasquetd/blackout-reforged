import 'dart:math';

/// Draws random entries without repetition until the whole pool has been
/// exhausted, then reshuffles and starts again. Mirrors the "shuffle bag"
/// pattern from the original app (a `remaining` list drained into a `used`
/// list, refilled once empty) but as a small reusable class instead of a
/// copy-pasted pair of static lists per content category.
class ContentPool {
  final List<String> _all = [];
  final List<String> _remaining = [];
  final Random _random;

  ContentPool(List<String> entries, {Random? random})
      : _random = random ?? Random() {
    _all.addAll(entries);
    _remaining.addAll(entries);
  }

  bool get isEmpty => _all.isEmpty;

  /// True right after the pool has cycled through every entry once.
  bool justExhausted = false;

  String draw() {
    if (_all.isEmpty) {
      throw StateError('Cannot draw from an empty content pool');
    }
    if (_remaining.isEmpty) {
      _remaining.addAll(_all);
      justExhausted = true;
    } else {
      justExhausted = false;
    }
    final index = _random.nextInt(_remaining.length);
    return _remaining.removeAt(index);
  }

  void addCustomEntries(List<String> entries) {
    _all.addAll(entries);
    _remaining.addAll(entries);
  }

  void reset() {
    _remaining
      ..clear()
      ..addAll(_all);
    justExhausted = false;
  }
}
