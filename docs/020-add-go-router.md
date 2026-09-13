# Navigation with go_router

Uses [`go_router`](https://pub.dev/packages/go_router) **18.x** — URL-based, declarative routing
(deep links, browser URLs, redirects) on top of Flutter's Router API.

> go_router 18 depends on **`material_ui`**. It detects the app type by looking for
> `material_ui`'s `MaterialApp`. With the old `package:flutter/material.dart` `MaterialApp` it silently falls
> back to plain pages without Material transitions. This project is migrated to `material_ui` —
> see [the migration notes](#material_ui-migration).

## Cases in this project

| Case | Where | API |
|---|---|---|
| Bottom navigation, state kept per tab | Home / Products / Profile | `StatefulShellRoute.indexedStack` |
| Path parameter | `/products/2` | `state.pathParameters['id']` |
| Query parameter | `/products?sort=price` | `state.uri.queryParameters['sort']` |
| Pass an object | product list → detail | `context.go(location, extra: product)` |
| Return a result | profile → edit name | `await context.push<String>(...)` + `context.pop(value)` |
| Auth guard + return to origin | `/profile`, `/checkout` | `redirect` + `refreshListenable` + `?from=` |
| Protected route with data | Buy → `/checkout?productId=3` | query params survive the login redirect (`extra` doesn't) |
| Disable back | order complete | `PopScope(canPop: false)` + `context.go` |
| Confirm unsaved changes | edit name | `PopScope(canPop: !hasChanges, onPopInvokedWithResult: ...)` |
| Full screen over the nav bar | edit name | `parentNavigatorKey: rootNavigatorKey` |
| 404 | any unknown URL | `errorBuilder` |

## Steps

### 1. Add dependency
```bash
flutter pub add "go_router:^18.0.1"
```

### 2. All locations in one place — `lib/router/routes.dart`
```dart
abstract final class Routes {
  static const home = '/';
  static const login = '/login';
  static const products = '/products';
  static String productsSortedBy(String sort) =>
      Uri(path: products, queryParameters: {'sort': sort}).toString();
  static String productDetail(String id) => '$products/$id';
  static const profile = '/profile';
  static const editProfile = '/profile/edit';
  static const checkout = '/checkout';
  static String checkoutFor(String productId) =>
      Uri(path: checkout, queryParameters: {'productId': productId}).toString();
  static const orderComplete = '/order-complete';

  static const protectedPrefixes = [profile, checkout];
}
```
Build URLs with `Uri(...)` — it encodes query values (`?q=a b&c` → `?q=a%20b%26c`).

### 3. Router — `lib/router/app_router.dart`
```dart
GoRouter createAppRouter(AuthController auth, {String initialLocation = Routes.home}) {
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    refreshListenable: auth,                              // re-run redirect on login/logout
    redirect: (context, state) => _authRedirect(auth, state),
    errorBuilder: (context, state) => NotFoundPage(location: state.uri.toString()),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => ScaffoldWithNavBar(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.home, builder: (context, state) => const HomePage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.products,
              builder: (context, state) => ProductListPage(sort: state.uri.queryParameters['sort']),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    final extra = state.extra;
                    return ProductDetailPage(
                      productId: id,
                      product: extra is Product ? extra : Product.findById(id),   // extra can be missing!
                      fromExtra: extra is Product,
                    );
                  },
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.profile,
              builder: (context, state) => const ProfilePage(),
              routes: [
                GoRoute(
                  path: 'edit',
                  parentNavigatorKey: rootNavigatorKey,       // above the bottom nav bar
                  builder: (context, state) => EditProfilePage(initialName: state.extra as String? ?? ''),
                ),
              ],
            ),
          ]),
        ],
      ),
      GoRoute(path: Routes.login, builder: (context, state) => LoginPage(from: state.uri.queryParameters['from'])),
      GoRoute(path: Routes.checkout, builder: ...),
      GoRoute(path: Routes.orderComplete, builder: ...),
      GoRoute(path: Routes.deviceInfo, builder: (context, state) => const DeviceInfoPage()),
      // ...other demo pages (top-level = full screen, no nav bar)
    ],
  );
}
```

### 4. App — `lib/main.dart`
```dart
class _MainAppState extends State<MainApp> {
  late final GoRouter _router = createAppRouter(widget.auth);   // create ONCE

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScope(
      notifier: widget.auth,
      child: MaterialApp.router(                                 // material_ui's MaterialApp
        routerConfig: _router,
        localizationsDelegates: appLocalizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }
}
```
Never create the `GoRouter` inside `build` — every rebuild (e.g. language change) would reset navigation.

## Navigating

| Call | Effect | Use for |
|---|---|---|
| `context.go('/products/2')` | Replaces the stack with the route's hierarchy (list → detail) | Tabs, links, "go to" |
| `context.push('/demos/pdf')` | Pushes on top, returns `Future<T?>` | Details, dialogs-as-pages, results |
| `context.pop([result])` | Pops the top page | Back / return a value |
| `context.replace(location)` | Replaces the top page | Wizard steps |
| `context.canPop()` | Is there a page to pop? | Custom back buttons |
| `context.goNamed('productDetail', pathParameters: {'id': '2'})` | Same as `go`, by route `name` | Avoid hard-coded paths |
| `shell.goBranch(index)` | Switch tab, keep its stack | Bottom navigation |

## Passing data

**Path parameter** — required, part of the identity:
```dart
GoRoute(path: ':id', builder: (context, state) => ProductDetailPage(id: state.pathParameters['id']!))
context.go(Routes.productDetail('2'));
```

**Query parameter** — optional, filters/sorting/pagination, bookmarkable:
```dart
builder: (context, state) => ProductListPage(sort: state.uri.queryParameters['sort'])
context.go(Routes.productsSortedBy('price'));
```

**`extra`** — any object, **not in the URL**:
```dart
context.go(Routes.productDetail(product.id), extra: product);
```
⚠️ `extra` is **lost** on web refresh, deep links, browser back/forward and **redirects** (e.g. login).
Always have a fallback (look it up by id) or use path/query params. For web state restoration you'd also need
`GoRouter(extraCodec: ...)`.

**Return a result**:
```dart
// caller
final newName = await context.push<String>(Routes.editProfile, extra: auth.userName);
if (newName != null) await auth.updateUserName(newName);

// callee
context.pop(_name.text.trim());
```
`go` doesn't return results — only `push`.

## Auth redirect
```dart
String? _authRedirect(AuthController auth, GoRouterState state) {
  final location = state.matchedLocation;
  final isProtected = Routes.protectedPrefixes.any(location.startsWith);

  if (!auth.isLoggedIn && isProtected) {
    return Uri(path: Routes.login, queryParameters: {'from': state.uri.toString()}).toString();
  }
  if (auth.isLoggedIn && location == Routes.login) {
    final from = state.uri.queryParameters['from'];
    // only in-app paths — prevents open redirects (?from=https://evil.example)
    return from != null && from.startsWith('/') && !from.startsWith('//') ? from : Routes.home;
  }
  return null;   // stay
}
```
- `refreshListenable: auth` — when `AuthController.notifyListeners()` fires, redirect re-runs:
  login page → back to `from`; logout on `/profile` → login page. The login page itself doesn't navigate.
- Redirects must be **fast and synchronous-ish**; keep auth state in memory (restored in `main()` before `runApp`).
- Watch for loops: a redirect that always returns a location hits `redirectLimit` (5) and shows the error page.
- `GoRoute(redirect: ...)` exists for per-route rules.

## Disable going back

**Completely** — after an order, payment, logout:
```dart
// CheckoutPage: go() replaces the stack, nothing to return to
context.go(Routes.orderCompleteFor(orderId));

// OrderCompletePage
PopScope(
  canPop: false,                                   // Android back, iOS swipe, browser back-to-app
  child: Scaffold(
    appBar: AppBar(automaticallyImplyLeading: false, title: ...),   // no back arrow
    body: FilledButton(onPressed: () => context.go(Routes.home), child: ...),
  ),
)
```

**Conditionally** — unsaved changes:
```dart
PopScope(
  canPop: !_hasChanges,
  onPopInvokedWithResult: (didPop, result) async {
    if (didPop) return;
    if (await confirmDiscardChanges(context) && context.mounted) context.pop();
  },
  child: ...,
)
```
- `WillPopScope` is deprecated and doesn't work with the Router API — use `PopScope`.
- `context.pop(result)` from your own Save button is **not** blocked by `PopScope`; only back gestures/buttons are.
- Route-level alternative: `GoRoute(onExit: (BuildContext context, GoRouterState state) async => confirm)` —
  return `false` to stay. Note the **two** parameters (some doc samples still show one).

## Bottom navigation — `lib/router/scaffold_with_nav_bar.dart`
```dart
Scaffold(
  body: shell,                                        // StatefulNavigationShell
  bottomNavigationBar: NavigationBar(
    selectedIndex: shell.currentIndex,
    onDestinationSelected: (index) =>
        shell.goBranch(index, initialLocation: index == shell.currentIndex),   // re-tap → tab root
    destinations: [...],
  ),
)
```
- `indexedStack` keeps every visited tab alive (scroll position, text fields).
- Pages that should cover the nav bar: top-level routes or `parentNavigatorKey: rootNavigatorKey`.

## Deep links & web
- **Web:** URLs work out of the box (`/#/products/2`). For clean URLs call `usePathUrlStrategy()` from
  `package:flutter_web_plugins/url_strategy.dart` before `runApp` and configure the server to serve
  `index.html` for all paths.
- **Android / iOS:** configure App Links (intent filter + `assetlinks.json`) / Universal Links
  (Associated Domains + `apple-app-site-association`). go_router receives the path and runs redirects as usual.
  See docs.flutter.dev/ui/navigation/deep-linking.
- Treat every location as untrusted input: validate ids, handle "not found".

## material_ui migration
go_router 18, pdfrx ≥ 2.5 and flutter_form_builder 11 depend on `material_ui`. Steps done in this project:
1. `dart fix --apply --code=migrate_design_widgets` — rewrites `package:flutter/material.dart` imports to
   `package:material_ui/material_ui.dart`.
2. Localization delegates from `material_ui` (the generated `AppLocalizations.localizationsDelegates` still point
   to `flutter_localizations`, which material_ui widgets can't see → "No MaterialLocalizations found"):
   ```dart
   final List<LocalizationsDelegate<dynamic>> appLocalizationDelegates = [
     AppLocalizations.delegate,
     ...GlobalMaterialLocalizations.delegates,     // material_ui: Widgets + Material + Cupertino
     FormBuilderLocalizations.delegate,
   ];
   ```
3. Packages still on `flutter/material.dart` (`country_flags`, `photo_view`) work without
   `MaterialUiCompatibilityBridge` here (it's deprecated) — they don't need a Material ancestor.

## Testing — `test/router_test.dart`
Start the real app at any location with mocked storage:
```dart
Future<AuthController> pumpApp(WidgetTester tester, {String location = Routes.home, bool signedIn = false}) async {
  FlutterSecureStorage.setMockInitialValues(signedIn ? {'auth_token': 't', 'auth_user_name': 'Ada'} : {});
  final auth = AuthController();
  await auth.restore();
  await tester.pumpWidget(MainApp(auth: auth, initialLocation: location));
  await tester.pumpAndSettle();
  return auth;
}

testWidgets('protected route redirects to login, then back after sign in', (tester) async {
  await pumpApp(tester, location: Routes.profile);
  expect(find.text('Sign in to open /profile'), findsOneWidget);
  await tester.enterText(find.byType(TextField), 'Ada');
  await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
  await tester.pumpAndSettle();
  expect(find.text('Signed in as Ada'), findsOneWidget);
});
```
Covered: redirect + return, logout redirect, path param, `extra`, query param, 404, checkout flow without back,
query param surviving login, `push`/`pop` result, unsaved-changes dialog (`tester.binding.handlePopRoute()` =
Android back).
- After `enterText`, `pumpAndSettle()` before tapping a button whose `enabled` state depends on the text.

## Troubleshooting
| Problem | Fix |
|---|---|
| No page transitions / plain error page | Using `flutter/material`'s `MaterialApp` → use `material_ui`'s `MaterialApp.router` |
| `No MaterialLocalizations found` | Use `material_ui` `GlobalMaterialLocalizations.delegates` |
| Navigation resets on language/theme change | `GoRouter` created in `build` → create once in `State` |
| `state.extra` is null | Opened via URL/refresh/redirect → fall back to id lookup or use params |
| Redirect loop / "too many redirects" | A redirect never returns `null` for its own target |
| Back button still works on a "no back" page | Missing `PopScope(canPop: false)` or page was `push`ed onto a stack |
| Login doesn't navigate | `refreshListenable` not set, or `notifyListeners()` not called |
