import 'package:flutter/foundation.dart';
import 'package:ipot/core/models/cart_item.dart';
import 'package:ipot/core/models/order_request.dart';
import 'package:ipot/core/models/order_status.dart';
import 'package:ipot/features/order/order_repository.dart';
import 'dart:async';

enum OrderState { initial, submitting, success, error, tracking }

class OrderProvider extends ChangeNotifier {
  final OrderRepository _repository;

  OrderProvider(this._repository);

  OrderState _state = OrderState.initial;
  OrderState get state => _state;

  OrderResponse? _currentOrder;
  OrderResponse? get currentOrder => _currentOrder;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Timer? _pollingTimer;

  Future<void> submitOrder({
    required String tableId,
    required List<CartItem> cartItems,
    String? customerNote,
  }) async {
    _state = OrderState.submitting;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = OrderRequest(
        tableId: tableId,
        items: cartItems
            .map(
              (cartItem) => OrderItemRequest(
                menuItemId: cartItem.menuItem.id,
                quantity: cartItem.quantity,
                customizations: cartItem.selectedOptions
                    .map(
                      (option) =>
                          OrderCustomizationRequest(optionId: option.id),
                    )
                    .toList(),
              ),
            )
            .toList(),
        customerNote: customerNote,
      );

      _currentOrder = await _repository.submitOrder(request);
      _state = OrderState.success;
      notifyListeners();

      startTracking(_currentOrder!.id);
    } catch (e) {
      _errorMessage = 'Failed to submit order. Please try again.';
      _state = OrderState.error;
      notifyListeners();
    }
  }

  void startTracking(String orderId) {
    _state = OrderState.tracking;
    notifyListeners();

    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final updated = await _repository.getOrderStatus(orderId);
      _currentOrder = updated;
      notifyListeners();

      if (!updated.status.isActive) {
        stopTracking();
      }
    });
  }

  void stopTracking() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void reset() {
    stopTracking();
    _state = OrderState.initial;
    _currentOrder = null;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}
