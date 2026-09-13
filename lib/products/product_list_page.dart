import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/l10n_extension.dart';
import '../router/routes.dart';
import 'product.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key, this.sort});

  /// From the query string: `/products?sort=price`. Anything else sorts by name.
  final String? sort;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sortBy = sort == 'price' ? 'price' : 'name';
    final products = [...Product.all]
      ..sort(sortBy == 'price'
          ? (a, b) => a.price.compareTo(b.price)
          : (a, b) => a.name.compareTo(b.name));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navProducts)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'name', label: Text(l10n.productsSortName)),
              ButtonSegment(value: 'price', label: Text(l10n.productsSortPrice)),
            ],
            selected: {sortBy},
            // `go` updates the URL (bookmarkable/shareable on web) instead of local state.
            onSelectionChanged: (selection) => context.go(Routes.productsSortedBy(selection.first)),
          ),
          const SizedBox(height: 8),
          for (final product in products)
            ListTile(
              title: Text(product.name),
              subtitle: Text(l10n.price(product.price)),
              trailing: const Icon(Icons.chevron_right),
              // Pass the object with `extra` to skip a lookup on the detail page.
              onTap: () => context.go(Routes.productDetail(product.id), extra: product),
            ),
        ],
      ),
    );
  }
}
