import 'package:flutter/material.dart';
import 'package:ipot/features/scanner/scanner_provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ScannerProvider>(
      builder: (context, provider, child) {
        final read = context.read<ScannerProvider>();

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: const Text("Scan Menu"),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(
                  provider.isTorchOn ? Icons.flash_on : Icons.flash_off,
                  color: provider.isTorchOn ? Colors.amber : Colors.black,
                ),
                onPressed: () => read.onToggleToch(),
              ),
            ],
          ),
          body: Stack(
            children: [
              // Main Scanner
              MobileScanner(
                controller: read.controller,
                onDetect: read.onDetect,
              ),

              // Hint Text
              Positioned(
                bottom: 40,
                left: 24,
                right: 24,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Text(
                      (provider.errorMessage?.isNotEmpty ?? false)
                          ? provider.errorMessage!
                          : 'Point the camera at the QR code on your table',
                      style: TextStyle(
                        color: (provider.errorMessage?.isNotEmpty ?? false)
                            ? Colors.redAccent
                            : Colors.white,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
