import 'package:flutter/material.dart';
import 'package:ipot/app_routes.dart';
import 'package:ipot/features/cart/cart_provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

class ScannerProvider extends ChangeNotifier {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final MobileScannerController controller = MobileScannerController();

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isTorchOn = false;
  bool get isTorchOn => _isTorchOn;

  void onToggleToch() {
    controller.toggleTorch();
    _isTorchOn = !_isTorchOn;
    notifyListeners();
  }

  bool validateCode(String rawCode) {
    // ipot://table/{tableId}
    final uri = Uri.tryParse(rawCode);
    if (uri == null || uri.scheme != 'ipot' || uri.pathSegments.isEmpty) {
      _errorMessage = 'Invalid QR code, please scan the code on your table';
      notifyListeners();
      return false;
    }

    return true;
  }

  String extractTableId(String rawCode) {
    return Uri.parse(rawCode).pathSegments.last;
  }

  void onDetect(BarcodeCapture capture) {
    try {
      final rawValue = capture.barcodes.firstOrNull?.rawValue;
      if (rawValue == null) return;

      if (!validateCode(rawValue)) return;

      String tableId = extractTableId(rawValue);
      debugPrint('Table ID: $tableId');

      if (tableId.isNotEmpty) {
        controller.stop();
        final context = scaffoldKey.currentContext!;
        context.read<CartProvider>().setTableId(tableId);
        Navigator.pushNamed(context, AppRoutes.menu, arguments: tableId);
      }
    } catch (e) {
      _errorMessage = 'Error processing QR code: $e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
