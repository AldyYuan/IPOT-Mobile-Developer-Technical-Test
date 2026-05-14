import 'package:flutter_test/flutter_test.dart';
import 'package:ipot/core/models/order_status.dart';
import 'package:ipot/core/models/order_request.dart';
import 'package:ipot/features/order/order_provider.dart';
import 'package:ipot/features/order/order_repository.dart';

// ── Fake repository ───────────────────────────────────────────────────────────

class _FakeOrderRepository extends OrderRepository {
  final bool shouldThrow;

  _FakeOrderRepository({this.shouldThrow = false});

  @override
  Future<OrderResponse> submitOrder(OrderRequest request) async {
    if (shouldThrow) throw Exception('network error');
    return OrderResponse(
      id: 'ORD-TEST',
      tableId: request.tableId,
      status: OrderStatusType.pending,
      estimatedMinutes: 15,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<OrderResponse> getOrderStatus(String orderId) async {
    return OrderResponse(
      id: orderId,
      tableId: 'T01',
      status: OrderStatusType.served, // immediately "served" to stop polling
      estimatedMinutes: null,
      createdAt: DateTime.now(),
    );
  }
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('OrderProvider – submit order', () {
    // 1. Successful submission transitions: initial → submitting → tracking.
    test('submitOrder transitions to tracking on success', () async {
      final provider = OrderProvider(_FakeOrderRepository());

      expect(provider.state, OrderState.initial);

      final future = provider.submitOrder(tableId: 'T01', cartItems: []);

      // During the await the state should be submitting.
      expect(provider.state, OrderState.submitting);

      await future;

      // After the call resolves, startTracking() has been called.
      expect(provider.state, OrderState.tracking);
      expect(provider.currentOrder, isNotNull);
      expect(provider.currentOrder!.id, 'ORD-TEST');
      expect(provider.errorMessage, isNull);
    });

    // 2. A network failure transitions to error with a message.
    test('submitOrder transitions to error when repository throws', () async {
      final provider = OrderProvider(_FakeOrderRepository(shouldThrow: true));

      await provider.submitOrder(tableId: 'T01', cartItems: []);

      expect(provider.state, OrderState.error);
      expect(provider.errorMessage, isNotNull);
      expect(provider.currentOrder, isNull);
    });

    // 3. reset() returns provider to clean initial state.
    test('reset clears order state after successful submission', () async {
      final provider = OrderProvider(_FakeOrderRepository());
      await provider.submitOrder(tableId: 'T01', cartItems: []);

      provider.reset();

      expect(provider.state, OrderState.initial);
      expect(provider.currentOrder, isNull);
      expect(provider.errorMessage, isNull);
    });
  });
}
