import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The small bracketed home icon the original app used, top-left, on every
/// in-game screen to bail out to the main menu.
class HomeIconButton extends StatelessWidget {
  final VoidCallback onPressed;

  const HomeIconButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Align(
        alignment: Alignment.topLeft,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.background,
              border: Border.all(color: AppTheme.accent, width: 1.5),
            ),
            child: const Icon(Icons.home_outlined, color: AppTheme.accent),
          ),
        ),
      ),
    );
  }
}
