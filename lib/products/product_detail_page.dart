import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/l10n_extension.dart';
import '../router/routes.dart';
import 'product.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({
    super.key,
    required this.productId,
    required this.product,
    required this.fromExtra,
  });

  final String productId;
  final Product? product;

  /// `true` when the object came via `extra`, `false` when looked up from the URL id.
  final bool fromExtra;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final product = this.product;

    if (product == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.productNotFound(productId))),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.price(product.price), style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(fromExtra ? l10n.productPassedWithExtra : l10n.productLoadedById),
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.shopping_cart),
            label: Text(l10n.productBuy),
            // Protected route → may redirect to login first, then come back here.
            onPressed: () => context.push(Routes.checkoutFor(product.id)),
          ),
        ],
      ),
    );
  }
}
