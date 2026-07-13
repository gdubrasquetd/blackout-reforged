enum Difficulty { soft, medium, hard }

/// The 5 special "event" mini-modes that can interrupt the normal
/// Action/Vérité loop. Consolidated here instead of 5 near-identical
/// Activities (RolePage/DuelPage/DilemPage/GlobalPage/MiniGamePage) and
/// 5 near-identical transition Activities as in the original app.
enum EventType {
  duel,
  dilem,
  global,
  minijeu,
  role;

  /// User-facing labels, matched to the original app's actual on-screen
  /// text -- which differs from the internal Java class names
  /// (GlobalPage/RolePage) that the enum values are named after.
  String get label => switch (this) {
        EventType.duel => 'Duel',
        EventType.dilem => 'Dilemme',
        EventType.global => 'Tournée',
        EventType.minijeu => 'Mini-jeu',
        EventType.role => 'Pouvoir',
      };

  String get transitionAsset => switch (this) {
        EventType.duel => 'assets/images/duelgif.gif',
        EventType.dilem => 'assets/images/dilemgif.gif',
        EventType.global => 'assets/images/globalgif.gif',
        EventType.minijeu => 'assets/images/minijeugif.gif',
        EventType.role => 'assets/images/rolegif.gif',
      };

  /// The banner graphic shown above the transition animation, matching the
  /// original's `duelbutton.png` / `dilembutton.png` / etc.
  String get bannerAsset => switch (this) {
        EventType.duel => 'assets/images/duelbutton.png',
        EventType.dilem => 'assets/images/dilembutton.png',
        EventType.global => 'assets/images/tourneebutton.png',
        EventType.minijeu => 'assets/images/minijeubutton.png',
        EventType.role => 'assets/images/rolebutton.png',
      };
}

enum EventFrequency {
  none(0),
  low(15),
  normal(25),
  high(35),
  veryHigh(45);

  final int probabilityPercent;
  const EventFrequency(this.probabilityPercent);

  String get label => switch (this) {
        EventFrequency.none => 'Aucun',
        EventFrequency.low => 'Faible',
        EventFrequency.normal => 'Normal',
        EventFrequency.high => 'Fréquent',
        EventFrequency.veryHigh => 'Très fréquent',
      };
}
