import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:blackout/screens/about_screen.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('renders the BOUTIQUE title and the "everything is free" copy',
      (tester) async {
    await pumpApp(tester, const AboutScreen());

    expect(find.text('BOUTIQUE'), findsOneWidget);
    expect(find.text('Rien à vendre ici, tout est GRATUIT !'), findsOneWidget);
  });

  testWidgets('renders the rate-us and feedback list tiles', (tester) async {
    await pumpApp(tester, const AboutScreen());

    expect(find.text('Noter BlackOut'), findsOneWidget);
    expect(find.text('Sur le Play Store'), findsOneWidget);
    expect(find.text('Laisser un avis / suggestion'), findsOneWidget);
    expect(find.text('Formulaire de retour'), findsOneWidget);
    expect(find.byIcon(Icons.star_outline), findsOneWidget);
    expect(find.byIcon(Icons.feedback_outlined), findsOneWidget);
  });

  testWidgets('both list tiles are tappable', (tester) async {
    await pumpApp(tester, const AboutScreen());

    final rateTile =
        tester.widget<ListTile>(find.widgetWithText(ListTile, 'Noter BlackOut'));
    final feedbackTile = tester.widget<ListTile>(
        find.widgetWithText(ListTile, 'Laisser un avis / suggestion'));

    expect(rateTile.onTap, isNotNull);
    expect(feedbackTile.onTap, isNotNull);
  });

  testWidgets(
      'shows a snackbar instead of crashing when the launcher throws',
      (tester) async {
    await pumpApp(
      tester,
      AboutScreen(
        launch: (url, {mode = LaunchMode.platformDefault}) =>
            throw Exception('no app can handle this URL'),
      ),
    );

    await tester.tap(find.widgetWithText(ListTile, 'Noter BlackOut'));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("Impossible d'ouvrir le Play Store."), findsOneWidget);
  });

  testWidgets(
      'shows a snackbar instead of crashing when the launcher returns false',
      (tester) async {
    await pumpApp(
      tester,
      AboutScreen(
        launch: (url, {mode = LaunchMode.platformDefault}) async => false,
      ),
    );

    await tester.tap(find.widgetWithText(ListTile, 'Laisser un avis / suggestion'));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("Impossible d'ouvrir le formulaire de retour."),
        findsOneWidget);
  });

  testWidgets('does not show a snackbar when the launcher succeeds',
      (tester) async {
    await pumpApp(
      tester,
      AboutScreen(
        launch: (url, {mode = LaunchMode.platformDefault}) async => true,
      ),
    );

    await tester.tap(find.widgetWithText(ListTile, 'Noter BlackOut'));
    await tester.pump();

    expect(find.byType(SnackBar), findsNothing);
  });
}
