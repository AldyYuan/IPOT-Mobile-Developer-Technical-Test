// core/models/cart_item.dart
import 'menu_item.dart';
import 'customization_option.dart';

class CartItem {
  final MenuItem menuItem;
  final int quantity;
  final List<CustomizationOption> selectedOptions;
  final String? note;

  const CartItem({
    required this.menuItem,
    required this.quantity,
    this.selectedOptions = const [],
    this.note,
  });

  double get subtotal {
    double total = menuItem.price;
    for (final option in selectedOptions) {
      total += option.priceModifier;
    }
    return total * quantity;
  }

  CartItem copyWith({
    int? quantity,
    List<CustomizationOption>? selectedOptions,
    String? note,
  }) {
    return CartItem(
      menuItem: menuItem,
      quantity: quantity ?? this.quantity,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      note: note ?? this.note,
    );
  }
}
