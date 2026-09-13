import 'package:flutter_best_practices/auth/auth_controller.dart';
import 'package:flutter_best_practices/main.dart';
import 'package:flutter_best_practices/router/routes.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Starts the real app (router + auth) at [location].
Future<AuthController> pumpApp(
  WidgetTester tester, {
  String location = Routes.home,
  bool signedIn = false,
}) async {
  FlutterSecureStorage.setMockInitialValues(
    signedIn ? {'auth_token': 'test-token', 'auth_user_name': 'Ada'} : {},
  );
  PackageInfo.setMockInitialValues(
    appName: 'Flutter Best Practices',
    packageName: 'com.example.app',
    version: '1.2.3',
    buildNumber: '4',
    buildSignature: '',
  );
  final auth = AuthController();
  await auth.restore();

  await tester.pumpWidget(MainApp(auth: auth, initialLocation: location));
  await tester.pumpAndSettle();
  return auth;
}

void main() {
  testWidgets('protected route redirects to login, then back after sign in', (tester) async {
    await pumpApp(tester, location: Routes.profile);

    expect(find.text('Sign in to open /profile'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Ada');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Signed in as Ada'), findsOneWidget);
    expect(find.text('Version 1.2.3 (4)'), findsOneWidget); // package_info_plus
  });

  testWidgets('sign out on a protected page redirects to login', (tester) async {
    await pumpApp(tester, location: Routes.profile, signedIn: true);

    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(find.text('Sign in to open /profile'), findsOneWidget);
  });

  testWidgets('path parameter: detail page looks the product up by id', (tester) async {
    await pumpApp(tester, location: Routes.productDetail('2'));

    expect(find.text('Mouse'), findsOneWidget);
    expect(find.text('Product looked up by the id in the URL.'), findsOneWidget);
  });

  testWidgets('extra: tapping a product passes the object', (tester) async {
    await pumpApp(tester, location: Routes.products);

    await tester.tap(find.text('Keyboard'));
    await tester.pumpAndSettle();

    expect(find.text('Product object passed with extra (no lookup).'), findsOneWidget);
    // Back arrow returns to the list inside the same tab.
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Monitor'), findsOneWidget);
  });

  testWidgets('query parameter: ?sort=price orders by price', (tester) async {
    await pumpApp(tester, location: Routes.productsSortedBy('price'));

    final mouseY = tester.getTopLeft(find.text('Mouse')).dy;
    final keyboardY = tester.getTopLeft(find.text('Keyboard')).dy;
    final monitorY = tester.getTopLeft(find.text('Monitor')).dy;
    expect(mouseY < keyboardY && keyboardY < monitorY, isTrue);
  });

  testWidgets('unknown location shows the 404 page', (tester) async {
    await pumpApp(tester, location: '/does-not-exist');

    expect(find.text('Page not found'), findsOneWidget);
    expect(find.text('There is no page for /does-not-exist'), findsOneWidget);
  });

  testWidgets('checkout flow ends on a page without back navigation', (tester) async {
    await pumpApp(tester, location: Routes.productDetail('1'), signedIn: true);

    await tester.tap(find.text('Buy'));
    await tester.pumpAndSettle();
    expect(find.text('Checkout'), findsOneWidget);

    await tester.tap(find.text('Place order'));
    await tester.pumpAndSettle();

    expect(find.text('Order complete'), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);
    expect(find.byWidgetPredicate((widget) => widget is PopScope && !widget.canPop), findsOneWidget);

    await tester.tap(find.text('Back to home'));
    await tester.pumpAndSettle();
    expect(find.text('Hello!'), findsOneWidget);
  });

  testWidgets('protected checkout keeps the query parameter through login', (tester) async {
    await pumpApp(tester, location: Routes.checkoutFor('3'));

    await tester.enterText(find.byType(TextField), 'Ada');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Checkout'), findsOneWidget);
    expect(find.text('Monitor'), findsOneWidget);
  });

  testWidgets('push<T>/pop(result): edit page returns the new name', (tester) async {
    await pumpApp(tester, location: Routes.profile, signedIn: true);

    await tester.tap(find.text('Edit name'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Grace');
    await tester.pumpAndSettle(); // rebuild so the Save button becomes enabled
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Signed in as Grace'), findsOneWidget);
    expect(find.text('Name updated'), findsOneWidget);
  });

  testWidgets('unsaved changes: back asks before leaving', (tester) async {
    await pumpApp(tester, location: Routes.profile, signedIn: true);

    await tester.tap(find.text('Edit name'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Grace');
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute(); // Android back button
    await tester.pumpAndSettle();
    expect(find.text('Leave this page?'), findsOneWidget);

    await tester.tap(find.text('Leave'));
    await tester.pumpAndSettle();
    expect(find.text('Signed in as Ada'), findsOneWidget); // name unchanged
  });
}
