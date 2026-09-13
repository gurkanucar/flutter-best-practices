# Ask for Store Reviews with in_app_review

Uses [`in_app_review`](https://pub.dev/packages/in_app_review) **2.0.x** — show the native rating dialog or open
the store page.

| | `requestReview()` | `openStoreListing()` |
|---|:-:|:-:|
| Android | ✅ Play In-App Review | ✅ |
| iOS | ✅ `SKStoreReviewController` | ✅ needs `appStoreId` |
| macOS | ✅ | ✅ needs `appStoreId` |
| Windows | ❌ | ✅ needs `microsoftStoreId` |
| Linux / Web | ❌ | ❌ |

## Steps

### 1. Add dependency
```bash
flutter pub add in_app_review
```
No platform setup.

### 2. Request a review (at the right moment)
```dart
import 'package:in_app_review/in_app_review.dart';

final review = InAppReview.instance;

if (await review.isAvailable()) {
  await review.requestReview();
}
```
**What you can't know or control:**
- Whether the dialog was shown, and whether/what the user rated — `requestReview()` returns nothing.
- The OS has a **quota** (iOS: max 3 times per 365 days; Play: undocumented, "time-bound"). Calling it more often
  silently does nothing.

So: **never call it from a "Rate us" button** (the user taps and nothing may happen). Use
`openStoreListing()` for buttons.

### 3. Open the store page (for buttons)
```dart
await review.openStoreListing(
  appStoreId: '1234567890',          // iOS/macOS: numeric id from App Store Connect
  microsoftStoreId: '9NXXXXXXXXXX',  // Windows
);                                    // Android uses the package name automatically
```

### 4. Decide when to ask — `lib/review/review_prompt_policy.dart`
Keep the rules in a pure class so they are testable:
```dart
const policy = ReviewPromptPolicy(
  minCompletedActions: 3,       // after the user succeeded a few times
  minDaysSinceFirstLaunch: 3,   // not on day one
  minDaysBetweenPrompts: 90,    // your own cool-down on top of the OS quota
);

if (policy.shouldAsk(completedActions: count, firstLaunch: first, lastPrompt: last, now: DateTime.now())) {
  await review.requestReview();
  // store lastPrompt = now (e.g. Hive, 021)
}
```
Tests: `test/review_prompt_policy_test.dart`.

Good moments: right after a successful action (order delivered, level finished). Bad moments: app start,
after an error, in the middle of a flow.

### 5. Demo — `lib/review/in_app_review_page.dart`
**Home → Demos → Rate the app**: "Complete an action" increments a counter; on the 3rd action the policy allows
the request. The "Open store page" button is disabled where the store id isn't configured
(`InAppReviewPage.appStoreId` / `microsoftStoreId`).

## Testing the dialog
| Platform | How |
|---|---|
| iOS | Debug build on simulator/device: dialog always shows (no real submit). **TestFlight: never shows.** Release: quota applies. |
| Android | Only for apps installed from Play — use an **internal testing track** or internal app sharing. A sideloaded debug APK does nothing. |
| macOS | Similar to iOS. |

## Notes
- Don't put incentives on reviews ("rate 5 stars for coins") — against store policies.
- Don't ask "Do you like the app?" first and only send happy users to the dialog (review gating) — Apple and Google
  disallow it.
