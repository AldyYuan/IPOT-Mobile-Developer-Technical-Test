import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ipot/app_routes.dart';
import 'package:ipot/features/menu/menu_provider.dart';
import 'package:ipot/features/menu/menu_repository.dart';
import 'package:ipot/features/scanner/scanner_provider.dart';
import 'package:ipot/features/scanner/scanner_screen.dart';
import 'package:ipot/shared/theme/button_theme.dart';
import 'package:ipot/shared/theme/text_field_theme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScannerProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider(MenuRepository())),
      ],
      child: MaterialApp(
        title: 'IPOT',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFBD0017)),
          inputDecorationTheme: TextFieldTheme.theme,
          elevatedButtonTheme: AppButtonTheme.elevated,
          outlinedButtonTheme: AppButtonTheme.outlined,
        ),
        routes: AppRoutes.routes,
        home: const ScannerScreen(),
      ),
    );
  }
}
