import 'package:flutter/material.dart';
import 'package:ipot/app_routes.dart';
import 'package:ipot/features/cart/widgets/cart_item_card.dart';
import 'package:ipot/features/order/order_provider.dart';
import 'package:provider/provider.dart';
import 'package:ipot/features/cart/cart_provider.dart';
import 'package:ipot/shared/theme/app_colors.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final tableId = cart.tableId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Order'),
        scrolledUnderElevation: 0,
        actions: [
          if (!cart.isEmpty)
            TextButton(
              onPressed: () => _confirmClearCart(context, cart),
              child: const Text(
                'Clear',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
        ],
      ),
      body: cart.isEmpty
          ? _buildEmptyState(context)
          : _buildCartContent(context, cart, tableId ?? ''),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 72,
            color: Colors.black12,
          ),
          const SizedBox(height: 16),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black45,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add items from the menu',
            style: TextStyle(color: Colors.black38),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Browse Menu'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(
    BuildContext context,
    CartProvider cart,
    String tableId,
  ) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: cart.items.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
            itemBuilder: (context, index) =>
                CartItemCard(item: cart.items[index], index: index),
          ),
        ),
        _buildOrderSummary(context, cart, tableId),
      ],
    );
  }

  Widget _buildOrderSummary(
    BuildContext context,
    CartProvider cart,
    String tableId,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Note field
          TextField(
            decoration: InputDecoration(
              hintText: 'Any note for the kitchen? (e.g. No MSG)',
              hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
              prefixIcon: const Icon(
                Icons.note_outlined,
                color: Colors.black38,
              ),
            ),
            onChanged: cart.updateNote,
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${cart.totalItemCount} ${cart.totalItemCount == 1 ? 'item' : 'items'}',
                style: const TextStyle(color: Colors.black45),
              ),
              Text(
                '\$${cart.subtotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final order = context.read<OrderProvider>();

                await order.submitOrder(
                  tableId: tableId,
                  cartItems: cart.items,
                );

                if (!context.mounted) return;

                if (order.state == OrderState.success ||
                    order.state == OrderState.tracking) {
                  cart.clear();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.orderTracking,
                    (route) => route.settings.name == AppRoutes.menu,
                  );
                } else if (order.state == OrderState.error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        order.errorMessage ?? 'Failed to place order',
                      ),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }
              },
              child: const Text('Place Order'),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearCart(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear cart?'),
        content: const Text('This will remove all items from your order.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              cart.clear();
              Navigator.pop(context);
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
