import 'package:flutter_best_practices/review/review_prompt_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const policy = ReviewPromptPolicy(); // 3 actions, 3 days, 90 days between prompts
  final firstLaunch = DateTime(2026, 9, 1);

  test('does not ask before enough completed actions', () {
    expect(policy.shouldAsk(completedActions: 2, firstLaunch: firstLaunch, now: DateTime(2026, 9, 10)), isFalse);
  });

  test('does not ask in the first days after install', () {
    expect(policy.shouldAsk(completedActions: 5, firstLaunch: firstLaunch, now: DateTime(2026, 9, 2)), isFalse);
  });

  test('asks when actions and days are enough', () {
    expect(policy.shouldAsk(completedActions: 3, firstLaunch: firstLaunch, now: DateTime(2026, 9, 4)), isTrue);
  });

  test('waits between prompts', () {
    final lastPrompt = DateTime(2026, 9, 5);
    expect(
      policy.shouldAsk(completedActions: 10, firstLaunch: firstLaunch, now: DateTime(2026, 10, 1), lastPrompt: lastPrompt),
      isFalse,
    );
    expect(
      policy.shouldAsk(completedActions: 10, firstLaunch: firstLaunch, now: DateTime(2026, 12, 10), lastPrompt: lastPrompt),
      isTrue,
    );
  });
}
