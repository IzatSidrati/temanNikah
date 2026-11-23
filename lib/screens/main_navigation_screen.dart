import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard_screen.dart';
import 'checklist_screen.dart';
import 'budget_screen.dart';
import 'guest_screen.dart';
import 'vendor_screen.dart';
import 'rundown_screen.dart';
import '../theme/app_theme.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppTheme.primaryRose,
        unselectedItemColor: AppTheme.textLight,
        selectedLabelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
        type: BottomNavigationBarType.fixed,
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
    );
  }
}

class VendorAndRundownTabScreen extends StatelessWidget {
  const VendorAndRundownTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Vendor & Rundown',
            style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            indicatorColor: AppTheme.primaryRose,
            indicatorWeight: 3,
            labelColor: AppTheme.primaryRose,
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
  }
}
