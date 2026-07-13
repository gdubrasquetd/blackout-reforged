import 'package:flutter/material.dart';

import '../error_reporting.dart';
import '../theme/app_theme.dart';

/// Repeats the original app's drink-icon pattern tile behind a screen,
/// matching the shipped `background_home.png` / `background.png` assets.
///
/// If the tile image is missing or fails to decode, the screen still works
/// -- it just falls back to the plain theme background color instead of the
/// pattern, logged via [reportError] rather than left as a silent blank.
class TiledBackground extends StatelessWidget {
  final Widget child;
  final String asset;

  const TiledBackground({
    super.key,
    required this.child,
    this.asset = 'assets/images/background_home.png',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        image: DecorationImage(
          image: AssetImage(asset),
          repeat: ImageRepeat.repeat,
          onError: (error, stackTrace) => reportError(
              error, stackTrace ?? StackTrace.current,
              context: 'TiledBackground($asset)'),
        ),
      ),
      child: child,
    );
  }
}
