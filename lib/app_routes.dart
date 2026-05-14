import 'package:flutter/material.dart';
import 'package:ipot/features/cart/cart_screen.dart';
import 'package:ipot/features/menu/menu_screen.dart';
import 'package:ipot/features/order/order_tracking_screen.dart';
import 'package:ipot/features/scanner/scanner_screen.dart';

class AppRoutes {
  static const String scanner = '/scanner';
  static const String menu = '/menu';
  static const String cart = '/cart';
  static const String orderTracking = '/order-tracking';

  static Map<String, WidgetBuilder> get routes => {
    scanner: (context) => const ScannerScreen(),
    menu: (context) => const MenuScreen(),
    cart: (context) => const CartScreen(),
    orderTracking: (context) => const OrderTrackingScreen(),
  };
}
