import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard_screen.dart';
import 'checklist_screen.dart';
import 'budget_screen.dart';
import 'guest_screen.dart';
import 'vendor_screen.dart';
import 'rundown_screen.dart';
import '../providers/wedding_provider.dart';
import '../services/pdf_service.dart';
import '../services/ad_service.dart';
import '../widgets/ad_banner_widget.dart';
import '../theme/app_theme.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _navigateToTab(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
      AdService().onTabSwitched();
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<WeddingProvider>().currentTheme;

    final List<Widget> screens = [
      DashboardScreen(onNavigateToTab: _navigateToTab),
      const ChecklistScreen(),
      const BudgetScreen(),
      const GuestScreen(),
      const VendorAndRundownTabScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AdBannerWidget(),
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppTheme.cardBorder, width: 1)),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _navigateToTab,
              selectedItemColor: palette.primary,
              unselectedItemColor: AppTheme.textLight,
              selectedLabelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
              unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Beranda',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.checklist_rtl_outlined),
                  activeIcon: Icon(Icons.checklist_rtl),
                  label: 'Checklist',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  activeIcon: Icon(Icons.account_balance_wallet),
                  label: 'Anggaran',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline),
                  activeIcon: Icon(Icons.people),
                  label: 'Tamu',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.event_note_outlined),
                  activeIcon: Icon(Icons.event_note),
                  label: 'Acara & Vendor',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VendorAndRundownTabScreen extends StatelessWidget {
  const VendorAndRundownTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeddingProvider>(
      builder: (context, provider, child) {
        final palette = provider.currentTheme;
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                'Vendor & Rundown',
                style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf_outlined, color: AppTheme.errorRed),
                  tooltip: 'Ekspor Rundown PDF',
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    if (provider.rundowns.isEmpty) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Belum ada rundown untuk diekspor.')),
                      );
                      return;
                    }
                    try {
                      await PdfService().exportRundownPdf(
                        context: context,
                        info: provider.weddingInfo,
                        rundowns: provider.rundowns,
                      );
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(content: Text('Gagal ekspor PDF: $e')),
                      );
                    }
                  },
                ),
              ],
              bottom: TabBar(
                indicatorColor: palette.primary,
                indicatorWeight: 3,
                labelColor: palette.primary,
                unselectedLabelColor: AppTheme.textMuted,
                labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.storefront_outlined, size: 20),
                    text: 'Mitra Vendor',
                  ),
                  Tab(
                    icon: Icon(Icons.schedule, size: 20),
                    text: 'Susunan Acara',
                  ),
                ],
              ),
            ),
            body: const TabBarView(
              children: [
                VendorScreen(),
                RundownScreen(),
              ],
            ),
          ),
        );
      },
    );
  }
}
