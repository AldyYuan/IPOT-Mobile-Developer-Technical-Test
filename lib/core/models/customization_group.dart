// core/models/customization_group.dart
import 'customization_option.dart';

class CustomizationGroup {
  final int id;
  final String name;
  final bool required;
  final int maxSelections;
  final List<CustomizationOption> options;

  const CustomizationGroup({
    required this.id,
    required this.name,
    required this.required,
    required this.maxSelections,
    required this.options,
  });

  factory CustomizationGroup.fromJson(Map<String, dynamic> json) =>
      CustomizationGroup(
        id: json['id'] as int,
        name: json['name'] as String,
        required: json['required'] as bool,
        maxSelections: json['max_selections'] as int,
        options: (json['options'] as List)
            .map((o) => CustomizationOption.fromJson(o as Map<String, dynamic>))
            .toList(),
      );
}
