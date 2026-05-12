import 'package:flutter/material.dart';
import 'package:ipot/core/models/cart_item.dart';
import 'package:ipot/features/cart/cart_provider.dart';
import 'package:ipot/features/menu/widgets/cart_item_sheet.dart';
import 'package:ipot/shared/theme/app_colors.dart';
import 'package:ipot/shared/widgets/stepper_button.dart';
import 'package:provider/provider.dart';

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final int index;

  const CartItemCard({super.key, required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();

    // Build group-name → selected option names map
    final List<(String, String)> lines = [];
    for (final group in item.menuItem.customizationGroups) {
      final selected = group.options
          .where((o) => item.selectedOptions.any((s) => s.id == o.id))
          .map((o) => o.name)
          .toList();
      if (selected.isNotEmpty) lines.add((group.name, selected.join(', ')));
    }

    return InkWell(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => CartItemSheet(item: item.menuItem),
      ),
      splashColor: AppColors.primary.withValues(alpha: 0.06),
      highlightColor: AppColors.primary.withValues(alpha: 0.03),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name
            Text(
              item.menuItem.name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            // Options + price
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (lines.isEmpty && item.note == null)
                        const Text(
                          'No customization',
                          style: TextStyle(fontSize: 12, color: Colors.black38),
                        )
                      else
                        ...lines.map(
                          (line) => Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 12,
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
                      if (item.note != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 12,
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
                                TextSpan(text: item.note),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '\$${item.subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Stepper bottom-right
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                StepperButton(
                  icon: item.quantity == 1
                      ? Icons.delete_outline
                      : Icons.remove,
                  onTap: () => cart.decrementItem(index),
                  isDestructive: item.quantity == 1,
                ),
                SizedBox(
                  width: 32,
                  child: Text(
                    '${item.quantity}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                StepperButton(
                  icon: Icons.add,
                  onTap: () => cart.incrementItem(index),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
