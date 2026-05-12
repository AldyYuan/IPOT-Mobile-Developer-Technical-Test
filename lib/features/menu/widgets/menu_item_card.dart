import 'package:flutter/material.dart';
import 'package:ipot/core/models/menu_item.dart';
import 'package:ipot/features/cart/cart_provider.dart';
import 'package:ipot/features/menu/widgets/cart_item_sheet.dart';
import 'package:ipot/features/menu/widgets/customization_bottom_sheet.dart';
import 'package:ipot/shared/theme/app_colors.dart';
import 'package:ipot/shared/widgets/stepper_button.dart';
import 'package:provider/provider.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItem item;

  const MenuItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showCustomizationSheet(context),
      splashColor: AppColors.primary.withValues(alpha: 0.08),
      highlightColor: AppColors.primary.withValues(alpha: 0.04),
      child: Row(
        children: [
          Expanded(child: _buildDetails(context)),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _buildImage(context),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: item.imageUrl != null
                ? Image.network(
                    item.imageUrl!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _imagePlaceholder(),
                  )
                : _imagePlaceholder(),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Consumer<CartProvider>(
                builder: (context, cart, _) {
                  final qty = cart.quantityFor(item.id);
                  if (qty > 0) {
                    return _buildStepper(context, cart, qty);
                  }
                  return OutlinedButton(
                    onPressed: () => _showCustomizationSheet(context),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('ADD'),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 100,
      height: 100,
      color: const Color(0xFFF0EDE8),
      child: const Icon(
        Icons.restaurant_rounded,
        color: Color(0xFFD4C9B8),
        size: 36,
      ),
    );
  }

  Widget _buildDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.description,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black45,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Text(
            '\$${item.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              item.customizationGroups.isNotEmpty ? 'Customizable' : " ",
              style: TextStyle(fontSize: 11, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper(BuildContext context, CartProvider cart, int qty) {
    // Customizable items: show count badge → tap opens sheet to add another variant
    if (item.customizationGroups.isNotEmpty) {
      return GestureDetector(
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => CartItemSheet(item: item),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.shopping_bag_outlined,
                size: 14,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                '$qty added',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Non-customizable: inline stepper
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StepperButton(
            icon: Icons.remove,
            onTap: () => cart.decrementByItemId(item.id),
          ),
          Text(
            '$qty',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          StepperButton(icon: Icons.add, onTap: () => cart.addItem(item)),
        ],
      ),
    );
  }

  void _showCustomizationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomizationBottomSheet(item: item),
    );
  }
}
