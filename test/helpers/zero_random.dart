import 'dart:math';

/// A fully deterministic [Random] whose every method returns the lowest
/// possible value. Useful to pin down which branch probabilistic game logic
/// takes in a test (e.g. forcing `nextInt(100) < frequency` to always hold).
class ZeroRandom implements Random {
  const ZeroRandom();

  @override
  int nextInt(int max) => 0;

  @override
  double nextDouble() => 0;

  @override
  bool nextBool() => false;
}
