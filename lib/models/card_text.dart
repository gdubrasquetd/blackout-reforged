/// Card content uses positional placeholders, ported from the original
/// Java `String.format(text, random, opposite, same, boy, girl)` calls:
///   %s   -> a random other player
///   %2$s -> a player of the opposite gender to whoever's turn it is
///   %3$s -> a player of the same gender
///   %4$s -> a male player
///   %5$s -> a female player
///
/// Dart's `String` has no positional-format built-in, so this replicates
/// just the subset of printf-style syntax the content actually uses.
String formatCard(
  String template, {
  required String random,
  required String opposite,
  required String same,
  required String boy,
  required String girl,
}) {
  final args = [random, opposite, same, boy, girl];
  final buffer = StringBuffer();
  var i = 0;
  while (i < template.length) {
    final char = template[i];
    if (char == '%' && i + 1 < template.length) {
      // %s -> next positional arg (always index 0 here, matching original usage)
      if (template[i + 1] == 's') {
        buffer.write(args[0]);
        i += 2;
        continue;
      }
      // %N$s -> explicit positional arg N (1-indexed). Custom cards are
      // free-typed by whoever is hosting the game (see PersonalizeScreen),
      // so an out-of-range N (there are only 5 args) must degrade to
      // leaving the placeholder untouched rather than crashing the draw.
      final match = RegExp(r'^(\d)\$s').firstMatch(template.substring(i + 1));
      if (match != null) {
        final n = int.parse(match.group(1)!);
        if (n >= 1 && n <= args.length) {
          buffer.write(args[n - 1]);
          i += 1 + match.end;
          continue;
        }
      }
    }
    buffer.write(char);
    i++;
  }
  return buffer.toString();
}
