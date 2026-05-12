import 'package:flutter/material.dart';
import 'package:ipot/core/models/cart_item.dart';
import 'package:ipot/core/models/customization_option.dart';
import 'package:ipot/core/models/menu_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  List<CartItem> get items => _items;

  bool get isEmpty => _items.isEmpty;
  int get totalItemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.subtotal);

  String? _customerNote;
  String? get customerNote => _customerNote;

  void updateNote(String value) {
    _customerNote = value.trim().isEmpty ? null : value.trim();
  }

  void addItem(
    MenuItem menuItem, {
    int quantity = 1,
    List<CustomizationOption> selectedOptions = const [],
    String? note,
  }) {
    final existingIndex = _items.indexWhere(
      (item) =>
          item.menuItem.id == menuItem.id &&
          _areOptionsEqual(item.selectedOptions, selectedOptions) &&
          item.note == note,
    );

    if (existingIndex != -1) {
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + quantity,
      );
    } else {
      _items.add(
        CartItem(
          menuItem: menuItem,
          quantity: quantity,
          selectedOptions: selectedOptions,
          note: note,
        ),
      );
    }

    notifyListeners();
  }

  void incrementItem(int index) {
    if (index < 0 || index >= _items.length) return;
    _items[index] = _items[index].copyWith(
      quantity: _items[index].quantity + 1,
    );
    notifyListeners();
  }

  void decrementItem(int index) {
    if (index < 0 || index >= _items.length) return;

    if (_items[index].quantity <= 1) {
      removeItem(index);
    } else {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity - 1,
      );
    }

    notifyListeners();
  }

  void replaceItem(
    int index, {
    required int quantity,
    required List<CustomizationOption> selectedOptions,
    String? note,
  }) {
    if (index < 0 || index >= _items.length) return;
    _items[index] = _items[index].copyWith(
      quantity: quantity,
      selectedOptions: selectedOptions,
      note: note,
    );
    notifyListeners();
  }

  void removeItem(int index) {
    if (index < 0 || index >= _items.length) return;
    _items.removeAt(index);
    notifyListeners();
  }

  /// Total quantity across all cart entries for a given menu item id
  int quantityFor(int menuItemId) => _items
      .where((i) => i.menuItem.id == menuItemId)
      .fold(0, (sum, i) => sum + i.quantity);

  /// Decrement the last cart entry for a given menu item id
  void decrementByItemId(int menuItemId) {
    final index = _items.lastIndexWhere((i) => i.menuItem.id == menuItemId);
    if (index != -1) decrementItem(index);
  }

  bool _areOptionsEqual(
    List<CustomizationOption> options1,
    List<CustomizationOption> options2,
  ) {
    if (options1.length != options2.length) return false;
    for (var option in options1) {
      if (!options2.any((o) => o.id == option.id)) {
        return false;
      }
    }
    return true;
  }

  void clear() {
    _items.clear();
    _customerNote = null;
    notifyListeners();
  }
}
