class CustomizationOption {
  final int id;
  final String name;
  final double priceModifier;

  const CustomizationOption({
    required this.id,
    required this.name,
    required this.priceModifier,
  });

  factory CustomizationOption.fromJson(Map<String, dynamic> json) =>
      CustomizationOption(
        id: json['id'] as int,
        name: json['name'] as String,
        priceModifier: (json['price_modifier'] as num).toDouble(),
      );
}
