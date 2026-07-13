import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The camera-viewfinder-style corner brackets the original app used to
/// frame every screen title ("JOUEURS", "PACKS", "PARAMETRES", ...).
class BracketTitle extends StatelessWidget {
  final String text;

  const BracketTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: CustomPaint(
        painter: _CornerBracketsPainter(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTheme.displayFont,
              fontSize: 44,
              color: Color(0xFFF5E9DC),
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _CornerBracketsPainter extends CustomPainter {
  static const _armLength = 22.0;
  static const _inset = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    void corner(Offset origin, Offset dx, Offset dy) {
      canvas.drawLine(origin, origin + dx, paint);
      canvas.drawLine(origin, origin + dy, paint);
    }

    corner(
      const Offset(_inset, _inset),
      const Offset(_armLength, 0),
      const Offset(0, _armLength),
    );
    corner(
      Offset(size.width - _inset, _inset),
      const Offset(-_armLength, 0),
      const Offset(0, _armLength),
    );
    corner(
      Offset(_inset, size.height - _inset),
      const Offset(_armLength, 0),
      const Offset(0, -_armLength),
    );
    corner(
      Offset(size.width - _inset, size.height - _inset),
      const Offset(-_armLength, 0),
      const Offset(0, -_armLength),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
