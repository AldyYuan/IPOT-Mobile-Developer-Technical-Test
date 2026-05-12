import 'package:flutter/material.dart';
import 'package:ipot/core/models/menu_item.dart';
import 'package:ipot/features/cart/cart_provider.dart';
import 'package:ipot/shared/theme/app_colors.dart';
import 'package:ipot/shared/widgets/stepper_button.dart';
import 'package:provider/provider.dart';

class CustomizationBottomSheet extends StatefulWidget {
  final MenuItem item;
  final int? editingCartIndex;
  final Map<int, Set<int>> initialSelections;
  final String? initialNote;

  const CustomizationBottomSheet({
    super.key,
    required this.item,
    this.editingCartIndex,
    this.initialSelections = const {},
    this.initialNote,
  });

  @override
  State<CustomizationBottomSheet> createState() =>
      CustomizationBottomSheetState();
}

class CustomizationBottomSheetState extends State<CustomizationBottomSheet> {
  final Map<int, Set<int>> _selectedOptionIds = {};
  late final TextEditingController _noteController;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    // Pre-fill if editing
    for (final entry in widget.initialSelections.entries) {
      _selectedOptionIds[entry.key] = Set.from(entry.value);
    }
    _noteController = TextEditingController(text: widget.initialNote ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  bool get _canAdd {
    // All required groups must have a selection
    for (final group in widget.item.customizationGroups) {
      if (group.required && (_selectedOptionIds[group.id]?.isEmpty ?? true)) {
        return false;
      }
    }
    return true;
  }

  double get _totalPrice {
    double total = widget.item.price;
    for (final group in widget.item.customizationGroups) {
      for (final option in group.options) {
        if (_selectedOptionIds[group.id]?.contains(option.id) ?? false) {
          total += option.priceModifier;
        }
      }
    }
    return total;
  }

  void _toggleOption(int groupId, int optionId, int maxSelections) {
    setState(() {
      _selectedOptionIds[groupId] ??= {};
      final group = _selectedOptionIds[groupId]!;

      if (group.contains(optionId)) {
        group.remove(optionId);
      } else {
        if (group.length >= maxSelections) {
          group.remove(group.first);
        }
        group.add(optionId);
      }
    });
  }

  void _addToCart(BuildContext context) {
    final allOptions = widget.item.customizationGroups
        .expand(
          (group) => group.options.where(
            (o) => _selectedOptionIds[group.id]?.contains(o.id) ?? false,
          ),
        )
        .toList();
    final note = _noteController.text.trim().isEmpty
        ? null
        : _noteController.text.trim();
    final cartProvider = context.read<CartProvider>();

    if (widget.editingCartIndex != null) {
      cartProvider.replaceItem(
        widget.editingCartIndex!,
        quantity: _quantity,
        selectedOptions: allOptions,
        note: note,
      );
    } else {
      cartProvider.addItem(
        widget.item,
        quantity: _quantity,
        selectedOptions: allOptions,
        note: note,
      );
    }

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.editingCartIndex != null
              ? '${widget.item.name} updated'
              : '${widget.item.name} (x$_quantity) added to cart',
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
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

            // Content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  // Image
                  if (widget.item.imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.item.imageUrl!,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                  if (widget.item.imageUrl != null) const SizedBox(height: 16),

                  // item Name
                  Text(
                    widget.item.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  // Item Price
                  Text(
                    '\$${widget.item.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Customization options
                  ...widget.item.customizationGroups.map(
                    (group) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              group.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (group.required)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Required',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Options
                        ...group.options.map((option) {
                          final selected =
                              _selectedOptionIds[group.id]?.contains(
                                option.id,
                              ) ??
                              false;

                          return GestureDetector(
                            onTap: () => _toggleOption(
                              group.id,
                              option.id,
                              group.maxSelections,
                            ),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primary.withValues(alpha: 0.08)
                                    : const Color(0xFFF8F5F0),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.primary
                                      : Colors.transparent,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    option.name,
                                    style: TextStyle(
                                      fontWeight: selected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: selected
                                          ? AppColors.primary
                                          : Colors.black87,
                                    ),
                                  ),
                                  if (option.priceModifier > 0)
                                    Text(
                                      '+\$${option.priceModifier.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.black45,
                                        fontSize: 13,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  // Note field
                  const Text(
                    'Special Request',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      hintText: 'e.g. No onion, extra sauce...',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Quantity + Add to Cart
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Quantity',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          StepperButton(
                            icon: Icons.remove,
                            onTap: _quantity > 1
                                ? () => setState(() => _quantity--)
                                : null,
                          ),
                          const SizedBox(width: 20),
                          Text(
                            '$_quantity',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 20),
                          StepperButton(
                            icon: Icons.add,
                            onTap: () => setState(() => _quantity++),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _canAdd ? () => _addToCart(context) : null,
                      child: Text(
                        'Add to Cart  •  \$${(_totalPrice * _quantity).toStringAsFixed(2)}',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
