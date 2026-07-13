import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'theme/app_theme.dart';

/// Single choke point every uncaught error in the app funnels through.
///
/// BlackOut has no backend and collects no analytics, so today this only
/// logs. If a crash reporting SDK (Crashlytics, Sentry...) is added later,
/// wiring it in means editing the body of this one function instead of
/// hunting down every catch block in the app.
void reportError(Object error, StackTrace stackTrace, {String? context}) {
  FlutterError.dumpErrorToConsole(
    FlutterErrorDetails(
      exception: error,
      stack: stackTrace,
      context: context == null ? null : ErrorDescription(context),
    ),
  );
}

/// Wires up global crash handling and runs [body] inside a guarded zone.
///
/// - [FlutterError.onError] catches errors thrown during widget build/layout/paint.
/// - [PlatformDispatcher.instance.onError] catches errors that escape the
///   Flutter framework entirely (e.g. a platform channel callback).
/// - [runZonedGuarded] catches everything else, notably unhandled
///   fire-and-forget `Future` rejections (async callbacks passed to
///   `onPressed` are never awaited, so their errors would otherwise vanish
///   after only a console print, leaving the UI stuck).
/// - [ErrorWidget.builder] replaces Flutter's default red screen with a
///   small in-theme message in release builds, so a layout bug in one
///   widget can't dump a wall of debug text in front of a real user.
void runGuarded(void Function() body) {
  FlutterError.onError = (details) {
    reportError(details.exception, details.stack ?? StackTrace.current,
        context: details.context?.toString() ?? 'FlutterError');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    reportError(error, stack, context: 'PlatformDispatcher');
    return true;
  };

  if (!kDebugMode) {
    ErrorWidget.builder = (details) => const _FriendlyErrorScreen();
  }

  runZonedGuarded(body, (error, stack) {
    reportError(error, stack, context: 'runZonedGuarded');
  });
}

/// Shown in place of a crashing widget subtree in release builds only --
/// debug builds keep Flutter's normal red error screen so bugs stay loud
/// during development.
class _FriendlyErrorScreen extends StatelessWidget {
  const _FriendlyErrorScreen();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: const Text(
        "Oups, un problème est survenu sur cet écran.",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white70, fontSize: 16),
      ),
    );
  }
}
