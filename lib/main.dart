import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/wedding_provider.dart';
import 'theme/app_theme.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/notification_service.dart';
import 'services/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi locale bahasa Indonesia untuk tanggal
  try {
    await initializeDateFormatting('id_ID', null);
  } catch (e) {
    debugPrint('DateFormatting initialization error: $e');
  }

  // Inisialisasi service notifikasi lokal
  try {
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('NotificationService initialization error: $e');
  }

  // Inisialisasi Google AdMob (Banner, Interstitial, Rewarded, Native)
  try {
    await AdService().initialize();
  } catch (e) {
    debugPrint('AdService initialization error: $e');
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
            title: 'Teman Nikah',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.buildTheme(provider.currentTheme),
            home: provider.isLoading
                ? const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(color: AppTheme.primaryRose),
                    ),
                  )
                : (provider.isOnboarded
                    ? const MainNavigationScreen()
                    : const OnboardingScreen()),
          );
        },
      ),
    );
  }
}
