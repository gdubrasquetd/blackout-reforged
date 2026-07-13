import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Recreates the original app's button look: a maroon box with an orange
/// border, offset behind a second box in the page background color to fake
/// a stacked-paper drop shadow (sampled from the shipped `button.png`).
class StackedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double height;

  const StackedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.height = 64,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return SizedBox(
      height: height + 8,
      child: Stack(
        children: [
          Positioned(
            left: 8,
            top: 8,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppTheme.background,
                border: Border.all(color: AppTheme.accent, width: 1.5),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            right: 8,
            bottom: 8,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppTheme.surface.withValues(alpha: enabled ? 1 : 0.5),
                border: Border.all(color: AppTheme.accent, width: 1.5),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onPressed,
                  child: Center(
                    child: DefaultTextStyle(
                      style: const TextStyle(
                        color: Color(0xFFF5E9DC),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
