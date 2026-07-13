import 'dart:async';

import 'package:flutter/material.dart';

import '../error_reporting.dart';
import '../models/game_enums.dart';
import '../theme/app_theme.dart';
import 'event_screen.dart';

/// Renders [assetPath], falling back to an empty box instead of a large
/// red error icon if the asset is missing or fails to decode -- this
/// screen auto-advances after 4 seconds regardless, so a broken banner/GIF
/// shouldn't be able to block or visually break the flow.
Widget _resilientAsset(String assetPath) {
  return Image.asset(
    assetPath,
    errorBuilder: (context, error, stackTrace) {
      reportError(error, stackTrace ?? StackTrace.current,
          context: 'Image.asset($assetPath)');
      return const SizedBox.shrink();
    },
  );
}

/// Plays the short animated "sting" before a special event, replacing 5
/// near-identical Activities (TransitionDuel/Dilem/Global/MiniJeu/Role) that
/// only differed in which banner/GIF and destination screen they used.
class TransitionScreen extends StatefulWidget {
  final EventType eventType;
  const TransitionScreen({super.key, required this.eventType});

  @override
  State<TransitionScreen> createState() => _TransitionScreenState();
}

class _TransitionScreenState extends State<TransitionScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 4), _proceed);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _proceed() {
    if (!mounted) return;
    _timer?.cancel();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => EventScreen(eventType: widget.eventType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border.all(color: AppTheme.accent, width: 4),
        ),
        child: GestureDetector(
          onTap: _proceed,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _resilientAsset(widget.eventType.bannerAsset),
                  ),
                  const SizedBox(height: 32),
                  _resilientAsset(widget.eventType.transitionAsset),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
