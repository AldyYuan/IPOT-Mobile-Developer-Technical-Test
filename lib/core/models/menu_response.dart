// core/models/menu_response.dart
import 'restaurant.dart';
import 'menu_category.dart';
import 'menu_item.dart';

class MenuResponse {
  final Restaurant restaurant;
  final List<MenuCategory> categories;
  final List<MenuItem> items;

  const MenuResponse({
    required this.restaurant,
    required this.categories,
    required this.items,
  });

  factory MenuResponse.fromJson(Map<String, dynamic> json) => MenuResponse(
    restaurant: Restaurant.fromJson(json['restaurant'] as Map<String, dynamic>),
    categories:
        (json['categories'] as List)
            .map((c) => MenuCategory.fromJson(c as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
    items: (json['items'] as List)
        .map((i) => MenuItem.fromJson(i as Map<String, dynamic>))
        .toList(),
  );
}
