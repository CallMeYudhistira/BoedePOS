import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/report_provider.dart';
import 'providers/price_log_provider.dart';
import 'ui/screens/home_screen.dart';
import 'core/navigation_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Warning: .env file not found or failed to load: $e");
  }
  runApp(const BoedePOSApp());
}

class BoedePOSApp extends StatelessWidget {
  const BoedePOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => PriceLogProvider()),
      ],
      child: MaterialApp(
        title: 'BoedePOS',
        debugShowCheckedModeBanner: false,
        navigatorKey: NavigationService.navigatorKey,
        scaffoldMessengerKey: NavigationService.messengerKey,
        theme: ThemeData(
          textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F678A)),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
