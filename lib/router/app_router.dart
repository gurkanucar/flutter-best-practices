import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../app_settings/app_settings_page.dart';
import '../auth/auth_controller.dart';
import '../auth/login_page.dart';
import '../checkout/checkout_page.dart';
import '../checkout/order_complete_page.dart';
import '../connectivity/connectivity_page.dart';
import '../device_info/device_info_page.dart';
import '../forms/form_fields_page.dart';
import '../forms/sign_up_form_page.dart';
import '../home_page.dart';
import '../products/product.dart';
import '../products/product_detail_page.dart';
import '../products/product_list_page.dart';
import '../profile/edit_profile_page.dart';
import '../profile/profile_page.dart';
import '../bluetooth/bluetooth_page.dart';
import '../config/environment_page.dart';
import '../media/image_demo_page.dart';
import '../permissions/permissions_page.dart';
import '../media/photo_viewer_page.dart';
import '../pdf/pdf_viewer_page.dart';
import '../storage/drift/todos_page.dart';
import '../storage/hive/notes_page.dart';
import 'not_found_page.dart';
import 'routes.dart';
import 'scaffold_with_nav_bar.dart';

GoRouter createAppRouter(AuthController auth, {String initialLocation = Routes.home}) {
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    // Re-run redirect whenever the user signs in or out.
    refreshListenable: auth,
    redirect: (context, state) => _authRedirect(auth, state),
    errorBuilder: (context, state) => NotFoundPage(location: state.uri.toString()),
    routes: [
      // Bottom navigation; each branch keeps its own navigation stack and scroll state.
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => ScaffoldWithNavBar(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                name: 'home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.products,
                name: 'products',
                // Query parameter: /products?sort=price
                builder: (context, state) =>
                    ProductListPage(sort: state.uri.queryParameters['sort']),
                routes: [
                  GoRoute(
                    // Path parameter: /products/2
                    path: ':id',
                    name: 'productDetail',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      // `extra` is only set when navigating in-app. Deep links, browser
                      // refresh and redirects don't have it → fall back to a lookup by id.
                      final extra = state.extra;
                      return ProductDetailPage(
                        productId: id,
                        product: extra is Product ? extra : Product.findById(id),
                        fromExtra: extra is Product,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                name: 'profile',
                builder: (context, state) => const ProfilePage(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    // Full screen above the bottom navigation bar.
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) =>
                        EditProfilePage(initialName: state.extra as String? ?? ''),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: Routes.login,
        name: 'login',
        builder: (context, state) => LoginPage(from: state.uri.queryParameters['from']),
      ),
      GoRoute(
        path: Routes.checkout,
        name: 'checkout',
        builder: (context, state) =>
            CheckoutPage(product: Product.findById(state.uri.queryParameters['productId'] ?? '')),
      ),
      GoRoute(
        path: Routes.orderComplete,
        name: 'orderComplete',
        builder: (context, state) =>
            OrderCompletePage(orderId: state.uri.queryParameters['orderId'] ?? '-'),
      ),
      GoRoute(path: Routes.deviceInfo, builder: (context, state) => const DeviceInfoPage()),
      GoRoute(path: Routes.connectivity, builder: (context, state) => const ConnectivityPage()),
      GoRoute(path: Routes.appSettings, builder: (context, state) => const AppSettingsPage()),
      GoRoute(path: Routes.signUpForm, builder: (context, state) => const SignUpFormPage()),
      GoRoute(path: Routes.formFields, builder: (context, state) => const FormFieldsPage()),
      GoRoute(path: Routes.hiveNotes, builder: (context, state) => const NotesPage()),
      GoRoute(path: Routes.driftTodos, builder: (context, state) => const TodosPage()),
      GoRoute(path: Routes.images, builder: (context, state) => const ImageDemoPage()),
      GoRoute(
        path: Routes.photoViewer,
        builder: (context, state) => PhotoViewerPage(args: state.extra as PhotoViewerArgs?),
      ),
      GoRoute(path: Routes.pdf, builder: (context, state) => const PdfViewerPage()),
      GoRoute(path: Routes.permissions, builder: (context, state) => const PermissionsPage()),
      GoRoute(path: Routes.bluetooth, builder: (context, state) => const BluetoothPage()),
      GoRoute(path: Routes.environment, builder: (context, state) => const EnvironmentPage()),
    ],
  );
}

String? _authRedirect(AuthController auth, GoRouterState state) {
  final location = state.matchedLocation;
  final isProtected = Routes.protectedPrefixes.any(location.startsWith);

  if (!auth.isLoggedIn && isProtected) {
    // Remember the full location (incl. query) to come back after login.
    return Uri(path: Routes.login, queryParameters: {'from': state.uri.toString()}).toString();
  }

  if (auth.isLoggedIn && location == Routes.login) {
    final from = state.uri.queryParameters['from'];
    // Only allow in-app paths (avoid open redirects like ?from=https://evil.example).
    return from != null && from.startsWith('/') && !from.startsWith('//') ? from : Routes.home;
  }

  return null; // no redirect
}
