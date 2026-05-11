class MenuCategory {
  final int id;
  final String name;
  final int sortOrder;

  const MenuCategory({
    required this.id,
    required this.name,
    required this.sortOrder,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) => MenuCategory(
    id: json['id'] as int,
    name: json['name'] as String,
    sortOrder: json['sort_order'] as int,
  );
}
