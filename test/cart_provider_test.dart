import 'package:flutter_test/flutter_test.dart';
import 'package:ipot/core/models/cart_item.dart';
import 'package:ipot/core/models/customization_option.dart';
import 'package:ipot/core/models/menu_item.dart';
import 'package:ipot/features/cart/cart_provider.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

MenuItem _makeItem({int id = 1, double price = 10.0}) => MenuItem(
  id: id,
  name: 'Item $id',
  description: '',
  price: price,
  categoryId: 1,
  customizationGroups: [],
);

CustomizationOption _makeOption({int id = 1, double modifier = 1.5}) =>
    CustomizationOption(id: id, name: 'Option $id', priceModifier: modifier);

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('CartProvider – item management', () {
    late CartProvider cart;

    setUp(() => cart = CartProvider());

    // 1. Adding a new item increases the count and computes the correct subtotal.
    test('addItem adds a new entry and calculates subtotal correctly', () {
      final item = _makeItem(price: 12.50);
      final option = _makeOption(modifier: 2.00); // +$2 per item

      cart.addItem(item, quantity: 2, selectedOptions: [option]);

      expect(cart.items.length, 1);
      expect(cart.totalItemCount, 2);
      // subtotal = (12.50 + 2.00) * 2 = 29.00
      expect(cart.subtotal, closeTo(29.00, 0.001));
    });

    // 2. Adding the same item+options again merges into one entry.
    test('addItem merges duplicate items instead of creating a new entry', () {
      final item = _makeItem();

      cart.addItem(item, quantity: 1);
      cart.addItem(item, quantity: 3);

      expect(cart.items.length, 1);
      expect(cart.items.first.quantity, 4);
    });

    // 3. Same item with different options is treated as a separate cart entry.
    test(
      'addItem treats same item with different options as separate entries',
      () {
        final item = _makeItem();
        final optionA = _makeOption(id: 1);
        final optionB = _makeOption(id: 2);

        cart.addItem(item, selectedOptions: [optionA]);
        cart.addItem(item, selectedOptions: [optionB]);

        expect(cart.items.length, 2);
      },
    );

    // 4. Decrementing to zero removes the item from the list.
    test('decrementItem removes entry when quantity reaches zero', () {
      cart.addItem(_makeItem(), quantity: 1);
      expect(cart.items.length, 1);

      cart.decrementItem(0);

      expect(cart.items.isEmpty, isTrue);
    });

    // 5. incrementItem / decrementItem adjust quantity correctly.
    test('incrementItem and decrementItem adjust quantity', () {
      cart.addItem(_makeItem(), quantity: 2);

      cart.incrementItem(0);
      expect(cart.items.first.quantity, 3);

      cart.decrementItem(0);
      expect(cart.items.first.quantity, 2);
    });

    // 6. clear() empties all items, resets tableId and customerNote.
    test('clear resets all cart state', () {
      cart.setTableId('T01');
      cart.addItem(_makeItem(), quantity: 2);
      cart.updateNote('No MSG');
      cart.clear();

      expect(cart.isEmpty, isTrue);
      expect(cart.tableId, isNull);
      expect(cart.customerNote, isNull);
    });
  });

  group('CartItem – subtotal calculation', () {
    // 7. CartItem.subtotal correctly sums base price + all option modifiers.
    test('subtotal accounts for multiple customization options', () {
      final item = _makeItem(price: 10.0);
      final cartItem = CartItem(
        menuItem: item,
        quantity: 3,
        selectedOptions: [
          _makeOption(id: 1, modifier: 1.0),
          _makeOption(id: 2, modifier: 0.5),
        ],
      );

      // (10.0 + 1.0 + 0.5) * 3 = 34.5
      expect(cartItem.subtotal, closeTo(34.5, 0.001));
    });
  });
}
