import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/l10n_extension.dart';
import '../products/product.dart';
import '../router/routes.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key, required this.product});

  final Product? product;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final product = this.product;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.checkoutTitle)),
      body: product == null
          ? Center(child: Text(l10n.productNotFound('?')))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ListTile(title: Text(product.name), subtitle: Text(l10n.price(product.price))),
                const SizedBox(height: 16),
                FilledButton(
                  // `go` replaces the stack: the checkout page is gone, so there is
                  // nothing to go back to — the next page also blocks the back button.
                  onPressed: () => context.go(
                    Routes.orderCompleteFor('${DateTime.now().millisecondsSinceEpoch % 100000}'),
                  ),
                  child: Text(l10n.checkoutPlaceOrder),
                ),
              ],
            ),
    );
  }
}
