/// Thrown when a bundled content deck (an `assets/content/*.json` file)
/// can't be read or parsed -- e.g. a corrupted asset shipped in a bad build,
/// or (as happened to the original app with `duel.json` and
/// `transitionHomme.json`) a malformed JSON file that silently broke a
/// whole deck in production.
///
/// Giving this its own type lets callers show a specific "couldn't load the
/// game content" message instead of an unrelated null-check crash days
/// later when the empty deck is first drawn from.
class ContentLoadException implements Exception {
  final String assetPath;
  final Object cause;

  ContentLoadException(this.assetPath, this.cause);

  @override
  String toString() => 'Failed to load game content from "$assetPath": $cause';
}
