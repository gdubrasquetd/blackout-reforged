import 'package:flutter/material.dart';

/// Colors sampled directly from the original app's shipped assets
/// (background.png / button.png / colorAccent) so the rewrite keeps the
/// same visual identity instead of a generic Material skin.
class AppTheme {
  static const background = Color(0xFF210009);
  static const surface = Color(0xFF430011);
  static const accent = Color(0xFFE36414);
  static const accentBright = Color(0xFFFF5722);

  static const displayFont = 'Bangers';

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accentBright,
      brightness: Brightness.dark,
      primary: accentBright,
      secondary: accent,
      surface: surface,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: displayFont,
          fontSize: 30,
          color: Color(0xFFF5E9DC),
          letterSpacing: 1,
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontFamily: displayFont,
          fontSize: 34,
          color: Color(0xFFF5E9DC),
        ),
        titleLarge: TextStyle(
          fontFamily: displayFont,
          fontSize: 26,
          color: Color(0xFFF5E9DC),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accent, width: 1),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? accentBright
              : Colors.white54,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? accentBright.withValues(alpha: 0.5)
              : Colors.white24,
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: accentBright,
        thumbColor: accentBright,
        inactiveTrackColor: Colors.white24,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? accentBright
              : Colors.transparent,
        ),
        side: const BorderSide(color: accent, width: 1.5),
      ),
    );
  }
}
