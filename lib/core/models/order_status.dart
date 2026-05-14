enum OrderStatusType {
  pending,
  confirmed,
  preparing,
  ready,
  served;

  static OrderStatusType fromString(String value) {
    return OrderStatusType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderStatusType.pending,
    );
  }

  String get label => switch (this) {
    OrderStatusType.pending => 'Pending',
    OrderStatusType.confirmed => 'Confirmed',
    OrderStatusType.preparing => 'Preparing',
    OrderStatusType.ready => 'Ready',
    OrderStatusType.served => 'Served',
  };

  bool get isActive => this != OrderStatusType.served;
}

class OrderResponse {
  final String id;
  final String tableId;
  final OrderStatusType status;
  final int? estimatedMinutes;
  final DateTime createdAt;

  const OrderResponse({
    required this.id,
    required this.tableId,
    required this.status,
    this.estimatedMinutes,
    required this.createdAt,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) => OrderResponse(
    id: json['id'] as String,
    tableId: json['table_id'] as String,
    status: OrderStatusType.fromString(json['status'] as String),
    estimatedMinutes: json['estimated_minutes'] as int?,
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}
