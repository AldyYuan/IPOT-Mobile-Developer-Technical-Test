import 'package:flutter/material.dart';
import 'package:ipot/features/cart/cart_screen.dart';
import 'package:ipot/features/menu/menu_screen.dart';
import 'package:ipot/features/scanner/scanner_screen.dart';

class AppRoutes {
  static const String scanner = '/scanner';
  static const String menu = '/menu';
  static const String cart = '/cart';

  static Map<String, WidgetBuilder> get routes => {
    scanner: (context) => const ScannerScreen(),
    menu: (context) => const MenuScreen(),
    cart: (context) => const CartScreen(),
  };
}
