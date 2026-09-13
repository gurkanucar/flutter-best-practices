import 'package:flutter_best_practices/config/app_environment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parseFlavor maps names and falls back to dev', () {
    expect(AppEnvironment.parseFlavor('prod'), AppFlavor.prod);
    expect(AppEnvironment.parseFlavor('staging'), AppFlavor.staging);
    expect(AppEnvironment.parseFlavor('typo'), AppFlavor.dev);
  });

  test(
    'without --dart-define the dev defaults are used',
    () {
      expect(AppEnvironment.flavor, AppFlavor.dev);
      expect(AppEnvironment.apiBaseUrl, 'https://dev.api.example.com');
      expect(AppEnvironment.isProduction, isFalse);
    },
    // e.g. `flutter test --dart-define-from-file=env/staging.json` changes the values.
    skip: AppEnvironment.isConfigured ? 'APP_FLAVOR passed on the command line' : false,
  );

  test('staging file values are picked up', () {
    expect(AppEnvironment.flavor, AppFlavor.staging);
    expect(AppEnvironment.apiBaseUrl, 'https://staging.api.example.com');
  }, skip: AppEnvironment.flavorName == 'staging' ? false : 'run with --dart-define-from-file=env/staging.json');
}
