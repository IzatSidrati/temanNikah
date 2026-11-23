import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/wedding_provider.dart';
import 'theme/app_theme.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi locale bahasa Indonesia untuk tanggal
  try {
    await initializeDateFormatting('id_ID', null);
  } catch (e) {
    debugPrint('DateFormatting initialization error: $e');
  }

  runApp(const NikahPlanApp());
}

class NikahPlanApp extends StatelessWidget {
  const NikahPlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeddingProvider()),
      ],
      child: Consumer<WeddingProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            title: 'TemanNikah - Persiapan Pernikahan',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.buildTheme(provider.currentTheme),
            home: const MainNavigationScreen(),
          );
        },
      ),
    );
  }
}
