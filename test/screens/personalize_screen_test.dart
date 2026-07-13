import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:blackout/screens/personalize_screen.dart';
import 'package:blackout/state/settings_state.dart';

import '../helpers/pump_app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('renders the title and both empty-state sections',
      (tester) async {
    final settings = SettingsState();
    await settings.load();
    await pumpApp(tester, const PersonalizeScreen(), settingsState: settings);

    expect(find.text('PERSONNALISER'), findsOneWidget);
    expect(find.text('Actions personnalisées'), findsOneWidget);
    expect(find.text('Vérités personnalisées'), findsOneWidget);
    expect(find.text('Aucune entrée pour le moment.'), findsNWidgets(2));
  });

  testWidgets('tapping + on Actions opens the "Ajouter une action" dialog',
      (tester) async {
    final settings = SettingsState();
    await settings.load();
    await pumpApp(tester, const PersonalizeScreen(), settingsState: settings);

    await tester.tap(find.byIcon(Icons.add_circle_outline).first);
    await tester.pumpAndSettle();

    expect(find.text('Ajouter une action'), findsOneWidget);
    expect(find.textContaining('Balises disponibles'), findsOneWidget);
  });

  testWidgets('tapping + on Vérités opens the "Ajouter une vérité" dialog',
      (tester) async {
    final settings = SettingsState();
    await settings.load();
    await pumpApp(tester, const PersonalizeScreen(), settingsState: settings);

    await tester.tap(find.byIcon(Icons.add_circle_outline).last);
    await tester.pumpAndSettle();

    expect(find.text('Ajouter une vérité'), findsOneWidget);
  });

  testWidgets('adding a custom action appends "Ou bois 3 gorgées !" and '
      'shows it in the list', (tester) async {
    final settings = SettingsState();
    await settings.load();
    await pumpApp(tester, const PersonalizeScreen(), settingsState: settings);

    await tester.tap(find.byIcon(Icons.add_circle_outline).first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Fais 10 pompes');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(settings.customActions.length, 1);
    expect(settings.customActions.first,
        'Fais 10 pompes\n\nOu bois 3 gorgées !');
    expect(find.textContaining('Fais 10 pompes'), findsOneWidget);
  });

  testWidgets('placeholder tags are converted to positional format specs',
      (tester) async {
    final settings = SettingsState();
    await settings.load();
    await pumpApp(tester, const PersonalizeScreen(), settingsState: settings);

    await tester.tap(find.byIcon(Icons.add_circle_outline).first);
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byType(TextField), 'Regarde -A, -O, -S, -H et -F');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(
      settings.customActions.first,
      startsWith(r'Regarde %s, %2$s, %3$s, %4$s et %5$s'),
    );
  });

  testWidgets('cancelling the dialog does not add an entry', (tester) async {
    final settings = SettingsState();
    await settings.load();
    await pumpApp(tester, const PersonalizeScreen(), settingsState: settings);

    await tester.tap(find.byIcon(Icons.add_circle_outline).first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Never saved');
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();

    expect(settings.customActions, isEmpty);
  });

  testWidgets('deleting an entry removes it from the list', (tester) async {
    final settings = SettingsState();
    await settings.load();
    settings.addCustom(isAction: true, text: 'Entrée à supprimer');
    await pumpApp(tester, const PersonalizeScreen(), settingsState: settings);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(settings.customActions, isEmpty);
    expect(find.text('Aucune entrée pour le moment.'), findsNWidgets(2));
  });

  testWidgets('shows a snackbar once the 20-entry cap is reached',
      (tester) async {
    final settings = SettingsState();
    await settings.load();
    for (var i = 0; i < SettingsState.maxCustomEntries; i++) {
      settings.addCustom(isAction: true, text: 'entry-$i');
    }
    await pumpApp(tester, const PersonalizeScreen(), settingsState: settings);

    await tester.tap(find.byIcon(Icons.add_circle_outline).first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'one too many');
    await tester.tap(find.text('OK'));
    await tester.pump(); // show the SnackBar

    expect(find.textContaining('Limite de 20 entrées atteinte'),
        findsOneWidget);
  });
}
