import 'package:flutter/material.dart';
import 'package:ipot/core/models/cart_item.dart';
import 'package:ipot/core/models/menu_item.dart';
import 'package:ipot/features/cart/cart_provider.dart';
import 'package:ipot/features/menu/widgets/customization_bottom_sheet.dart';
import 'package:ipot/shared/theme/app_colors.dart';
import 'package:ipot/shared/widgets/stepper_button.dart';
import 'package:provider/provider.dart';

class CartItemSheet extends StatelessWidget {
  final MenuItem item;

  const CartItemSheet({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Cart entries for this item
          Consumer<CartProvider>(
            builder: (context, cart, _) {
              final entries = cart.items
                  .asMap()
                  .entries
                  .where((e) => e.value.menuItem.id == item.id)
                  .toList();

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: entries.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final index = entries[i].key;
                  final cartItem = entries[i].value;
                  return _CartEntryRow(
                    menuItem: item,
                    cartItem: cartItem,
                    cartIndex: index,
                    onEdit: () {
                      Navigator.pop(context);
                      _showEditSheet(context, cartItem, index);
                    },
                  );
                },
              );
            },
          ),
          const Divider(height: 1),
          // Customize Another button
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => CustomizationBottomSheet(item: item),
                  );
                },
                child: const Text('Customize Another'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context, CartItem existing, int cartIndex) {
    // Build initialSelections map from existing cart item
    final Map<int, Set<int>> initialSelections = {};
    for (final group in item.customizationGroups) {
      final selectedIds = group.options
          .where((o) => existing.selectedOptions.any((s) => s.id == o.id))
          .map((o) => o.id)
          .toSet();
      if (selectedIds.isNotEmpty) initialSelections[group.id] = selectedIds;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomizationBottomSheet(
        item: item,
        editingCartIndex: cartIndex,
        initialSelections: initialSelections,
        initialNote: existing.note,
      ),
    );
  }
}

class _CartEntryRow extends StatelessWidget {
  final MenuItem menuItem;
  final CartItem cartItem;
  final int cartIndex;
  final VoidCallback onEdit;

  const _CartEntryRow({
    required this.menuItem,
    required this.cartItem,
    required this.cartIndex,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();

    // Build group-name → selected option names map
    final List<(String, String)> lines = [];
    for (final group in menuItem.customizationGroups) {
      final selected = group.options
          .where((o) => cartItem.selectedOptions.any((s) => s.id == o.id))
          .map((o) => o.name)
          .toList();
      if (selected.isNotEmpty) lines.add((group.name, selected.join(', ')));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Options + price top row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (lines.isEmpty)
                      const Text(
                        'No customization',
                        style: TextStyle(fontSize: 13, color: Colors.black45),
                      )
                    else
                      ...lines.map(
                        (line) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                              children: [
                                TextSpan(
                                  text: '${line.$1}: ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                TextSpan(text: line.$2),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (cartItem.note != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                            children: [
                              const TextSpan(
                                text: 'Special Request: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              TextSpan(text: cartItem.note),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '\$${cartItem.subtotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Edit + stepper bottom right
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.edit_outlined, size: 16),
                ),
              ),
              const SizedBox(width: 8),
              StepperButton(
                icon: Icons.remove,
                onTap: () => cart.decrementItem(cartIndex),
              ),
              const SizedBox(width: 12),
              Text(
                '${cartItem.quantity}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 12),
              StepperButton(
                icon: Icons.add,
                onTap: () => cart.incrementItem(cartIndex),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
