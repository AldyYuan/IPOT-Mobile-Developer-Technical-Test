import '../../core/models/order_request.dart';
import '../../core/models/order_status.dart';

class OrderRepository {
  Future<OrderResponse> submitOrder(OrderRequest request) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    return OrderResponse(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      tableId: request.tableId,
      status: OrderStatusType.pending,
      estimatedMinutes: 15,
      createdAt: DateTime.now(),
    );
  }

  Future<OrderResponse> getOrderStatus(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return OrderResponse(
      id: orderId,
      tableId: 'T001',
      status: OrderStatusType.confirmed,
      estimatedMinutes: 12,
      createdAt: DateTime.now(),
    );
  }
}
