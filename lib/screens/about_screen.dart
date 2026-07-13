import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../error_reporting.dart';
import '../theme/app_theme.dart';
import '../widgets/bracket_title.dart';

/// Matches [launchUrl]'s signature so it can be swapped for a fake in
/// tests -- without this, a widget test tapping these tiles would reach the
/// real url_launcher platform implementation (which, on desktop test hosts,
/// can genuinely open a browser as a side effect of running the test suite).
typedef UrlLauncher = Future<bool> Function(Uri url,
    {LaunchMode mode});

Future<bool> _defaultLaunch(Uri url, {LaunchMode mode = LaunchMode.platformDefault}) =>
    launchUrl(url, mode: mode);

/// The original "Boutique" (ShopPage) despite its name wasn't an in-app
/// purchase shop, just a "rate us" + feedback form page. Kept the name and
/// tone for fidelity -- players expect a "Boutique" entry on the menu.
class AboutScreen extends StatelessWidget {
  final UrlLauncher _launch;

  const AboutScreen({super.key, UrlLauncher launch = _defaultLaunch})
      : _launch = launch;

  static const _packageId = 'fr.guillaume.blackout';
  static const _feedbackUrl =
      'https://docs.google.com/forms/d/e/1FAIpQLSc6NvKFj0bwG2Q-lXhbrQRjxUxiswv73g7vjvHwPAd8q9-Y3Q/viewform';

  /// Wraps a launch attempt so a device with no browser/store app -- or any
  /// other platform failure -- shows the player a snackbar instead of
  /// throwing an unhandled [PlatformException] from an `onTap` callback.
  Future<void> _tryLaunch(BuildContext context, Future<bool> Function() open,
      {required String failureMessage}) async {
    var succeeded = false;
    try {
      succeeded = await open();
    } catch (error, stackTrace) {
      reportError(error, stackTrace, context: 'AboutScreen._tryLaunch');
    }
    if (!succeeded && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failureMessage)));
    }
  }

  Future<void> _openStoreListing(BuildContext context) => _tryLaunch(
        context,
        () async {
          final appUri = Uri.parse('market://details?id=$_packageId');
          if (await _launch(appUri)) return true;
          return _launch(Uri.parse(
              'https://play.google.com/store/apps/details?id=$_packageId'));
        },
        failureMessage: "Impossible d'ouvrir le Play Store.",
      );

  Future<void> _openFeedbackForm(BuildContext context) => _tryLaunch(
        context,
        () => _launch(Uri.parse(_feedbackUrl),
            mode: LaunchMode.externalApplication),
        failureMessage: "Impossible d'ouvrir le formulaire de retour.",
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const BracketTitle('BOUTIQUE'),
              const Text(
                'Rien à vendre ici, tout est GRATUIT !',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Mais si tu souhaites nous soutenir, tu peux laisser une '
                'bonne note sur le Play Store ou partager tes idées '
                "d'actions, de vérités ou d'événements.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.star_outline, color: AppTheme.accent),
                title: const Text('Noter BlackOut'),
                subtitle: const Text('Sur le Play Store'),
                onTap: () => _openStoreListing(context),
              ),
              ListTile(
                leading:
                    const Icon(Icons.feedback_outlined, color: AppTheme.accent),
                title: const Text('Laisser un avis / suggestion'),
                subtitle: const Text('Formulaire de retour'),
                onTap: () => _openFeedbackForm(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
