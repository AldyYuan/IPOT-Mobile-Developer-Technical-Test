class OrderItemRequest {
  final int menuItemId;
  final int quantity;
  final List<OrderCustomizationRequest> customizations;

  const OrderItemRequest({
    required this.menuItemId,
    required this.quantity,
    this.customizations = const [],
  });

  Map<String, dynamic> toJson() => {
    'menu_item_id': menuItemId,
    'quantity': quantity,
    'customizations': customizations.map((c) => c.toJson()).toList(),
  };
}

class OrderCustomizationRequest {
  final int optionId;
  final int quantity;

  const OrderCustomizationRequest({required this.optionId, this.quantity = 1});

  Map<String, dynamic> toJson() => {
    'option_id': optionId,
    'quantity': quantity,
  };
}

class OrderRequest {
  final String tableId;
  final List<OrderItemRequest> items;
  final String? customerNote;

  const OrderRequest({
    required this.tableId,
    required this.items,
    this.customerNote,
  });

  Map<String, dynamic> toJson() => {
    'table_id': tableId,
    'items': items.map((i) => i.toJson()).toList(),
    if (customerNote != null) 'customer_note': customerNote,
  };
}
