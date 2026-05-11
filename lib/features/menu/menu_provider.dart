import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ipot/core/models/menu_category.dart';
import 'package:ipot/core/models/menu_item.dart';
import 'package:ipot/core/models/restaurant.dart';
import 'package:ipot/features/menu/menu_repository.dart';

enum MenuState { initial, loading, success, error }

class MenuProvider extends ChangeNotifier {
  final MenuRepository _repository;

  MenuProvider(this._repository);

  MenuState _state = MenuState.initial;
  MenuState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Restaurant? _restaurant;
  Restaurant? get restaurant => _restaurant;

  List<MenuItem> _menuItems = [];
  List<MenuItem> get menuItems => _menuItems;

  List<MenuCategory> _categories = [];
  List<MenuCategory> get categories => _categories;

  int _selectedCategoryId = -1; // -1 means "All"
  int get selectedCategoryId => _selectedCategoryId;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void selectCategory(int categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<MenuItem> get filteredItems {
    var items = _menuItems;

    if (_selectedCategoryId != -1) {
      items = items
          .where((item) => item.categoryId == _selectedCategoryId)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      items = items
          .where(
            (item) =>
                item.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    return items;
  }

  Future<void> init(String tableId) async {
    try {
      _state = MenuState.loading;
      _errorMessage = null;
      notifyListeners();

      var res = await _repository.getMenu(tableId);

      _restaurant = res.restaurant;
      _menuItems = res.items;
      _categories = res.categories;

      _state = MenuState.success;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading menu: $e');
      _errorMessage = 'Failed to load menu. Please try again.';
      _state = MenuState.error;
    }
  }
}
