/// Decides WHEN to call `InAppReview.requestReview()`.
///
/// The OS enforces its own quota and may silently show nothing, so ask only at a good moment:
/// after the user got value from the app, not on first launch, not too often.
class ReviewPromptPolicy {
  const ReviewPromptPolicy({
    this.minCompletedActions = 3,
    this.minDaysSinceFirstLaunch = 3,
    this.minDaysBetweenPrompts = 90,
  });

  /// e.g. finished orders, completed levels, saved notes.
  final int minCompletedActions;
  final int minDaysSinceFirstLaunch;
  final int minDaysBetweenPrompts;

  bool shouldAsk({
    required int completedActions,
    required DateTime firstLaunch,
    required DateTime now,
    DateTime? lastPrompt,
  }) {
    if (completedActions < minCompletedActions) return false;
    if (now.difference(firstLaunch).inDays < minDaysSinceFirstLaunch) return false;
    if (lastPrompt != null && now.difference(lastPrompt).inDays < minDaysBetweenPrompts) return false;
    return true;
  }
}
