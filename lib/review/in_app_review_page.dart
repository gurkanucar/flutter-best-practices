import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/l10n_extension.dart';
import 'review_prompt_policy.dart';

class InAppReviewPage extends StatefulWidget {
  const InAppReviewPage({super.key});

  /// Set after publishing. iOS/macOS need the numeric App Store id, Windows the Microsoft Store id.
  /// Android uses the package name automatically.
  static const appStoreId = '';
  static const microsoftStoreId = '';

  @override
  State<InAppReviewPage> createState() => _InAppReviewPageState();
}

class _InAppReviewPageState extends State<InAppReviewPage> {
  final _review = InAppReview.instance;

  // Demo: no minimum days so the prompt can be triggered right away.
  // A real app persists these values (e.g. in the Hive settings box) and keeps the defaults.
  static const _policy = ReviewPromptPolicy(minDaysSinceFirstLaunch: 0);
  final _firstLaunch = DateTime.now();
  int _completedActions = 0;
  DateTime? _lastPrompt;
  bool? _available;
  String? _message;

  bool get _isMobileStorePlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  bool get _canOpenStoreListing {
    if (kIsWeb) return false;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => true,
      TargetPlatform.iOS || TargetPlatform.macOS => InAppReviewPage.appStoreId.isNotEmpty,
      TargetPlatform.windows => InAppReviewPage.microsoftStoreId.isNotEmpty,
      _ => false,
    };
  }

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    // Returns false on unsupported platforms instead of throwing.
    final available = _isMobileStorePlatform && await _review.isAvailable();
    if (mounted) setState(() => _available = available);
  }

  /// Simulates a meaningful action (e.g. completed order). The policy decides if we ask now.
  Future<void> _completeAction() async {
    final l10n = context.l10n;
    setState(() => _completedActions++);

    final now = DateTime.now();
    final shouldAsk = _policy.shouldAsk(
      completedActions: _completedActions,
      firstLaunch: _firstLaunch,
      now: now,
      lastPrompt: _lastPrompt,
    );
    if (!shouldAsk || _available != true) return;

    await _review.requestReview(); // no result: the OS may show nothing (quota)
    if (!mounted) return;
    setState(() {
      _lastPrompt = now;
      _message = l10n.reviewRequested;
    });
  }

  Future<void> _openStoreListing() => _review.openStoreListing(
        appStoreId: InAppReviewPage.appStoreId.isEmpty ? null : InAppReviewPage.appStoreId,
        microsoftStoreId: InAppReviewPage.microsoftStoreId.isEmpty ? null : InAppReviewPage.microsoftStoreId,
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reviewTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!_isMobileStorePlatform) Text(l10n.reviewUnsupported),
          ListTile(
            leading: const Icon(Icons.rate_review),
            title: Text(l10n.reviewAvailable(_available == null ? '…' : (_available! ? l10n.yes : l10n.no))),
          ),
          const SizedBox(height: 8),
          Text(l10n.reviewWillAsk),
          const SizedBox(height: 8),
          FilledButton.icon(
            icon: const Icon(Icons.check),
            label: Text(l10n.reviewCompleteAction),
            onPressed: _completeAction,
          ),
          const SizedBox(height: 8),
          Text(l10n.reviewProgress(_completedActions)),
          if (_message != null) ...[
            const SizedBox(height: 8),
            Text(_message!, style: Theme.of(context).textTheme.titleMedium),
          ],
          const Divider(height: 32),
          // A permanent "Rate us" entry must use openStoreListing — requestReview has a quota.
          OutlinedButton.icon(
            icon: const Icon(Icons.storefront),
            label: Text(l10n.reviewOpenStore),
            onPressed: _canOpenStoreListing ? _openStoreListing : null,
          ),
          if (!_canOpenStoreListing && _isMobileStorePlatform)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(l10n.reviewStoreIdMissing, style: Theme.of(context).textTheme.bodySmall),
            ),
        ],
      ),
    );
  }
}
