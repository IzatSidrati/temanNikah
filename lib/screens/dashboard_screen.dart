import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/wedding_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/countdown_widget.dart';
import '../widgets/budget_summary_card.dart';
import '../widgets/section_header.dart';
import '../widgets/wedding_edit_dialog.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int) onNavigateToTab;

  const DashboardScreen({
    super.key,
    required this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<WeddingProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.primaryRose),
            ),
          );
        }

        final info = provider.weddingInfo;
        final upcomingChecklist = provider.checklist.where((c) => !c.isDone).take(3).toList();

        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite, color: AppTheme.primaryRose, size: 20),
                const SizedBox(width: 8),
                Text(
                  'TemanNikah',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: AppTheme.textDark),
                tooltip: 'Pengaturan',
                onPressed: () {
                  _showSettingsBottomSheet(context, provider);
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            color: AppTheme.primaryRose,
            onRefresh: () => provider.loadData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header Countdown Widget
                  CountdownWidget(
                    info: info,
                    days: provider.daysRemaining,
                    hours: provider.hoursRemaining,
                    minutes: provider.minutesRemaining,
                    palette: provider.currentTheme,
                    onEdit: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => WeddingEditDialog(
                          initialInfo: info,
                          onSave: (updated) => provider.updateWeddingInfo(updated),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // 2. Ringkasan Cepat 4 Kotak
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.checklist_rtl_rounded,
                          iconColor: AppTheme.primaryRose,
                          title: 'Persiapan',
                          value: '${(provider.checklistProgress * 100).toInt()}%',
                          subtitle: '${provider.completedChecklistCount}/${provider.totalChecklistCount} Selesai',
                          onTap: () => onNavigateToTab(1), // Tab Checklist
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.people_alt_outlined,
                          iconColor: AppTheme.infoBlue,
                          title: 'Undangan Tamu',
                          value: '${provider.totalGuests}',
                          subtitle: '${provider.totalAttendingGuests} Konfirmasi Hadir',
                          onTap: () => onNavigateToTab(3), // Tab Tamu
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.storefront_outlined,
                          iconColor: AppTheme.accentGold,
                          title: 'Mitra Vendor',
                          value: '${provider.vendors.length}',
                          subtitle: 'Vendor Aktif',
                          onTap: () => onNavigateToTab(4), // Tab Vendor
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.savings_outlined,
                          iconColor: AppTheme.successGreen,
                          title: 'Sisa Anggaran',
                          value: Formatters.currency(provider.remainingBudget),
                          subtitle: 'Dari ${Formatters.currency(provider.totalBudget)}',
                          isSmallText: true,
                          onTap: () => onNavigateToTab(2), // Tab Budget
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 3. Ringkasan Anggaran & Pengeluaran
                  BudgetSummaryCard(
                    totalBudget: provider.totalBudget,
                    spentBudget: provider.totalActualExpense,
                    paidBudget: provider.totalPaidExpense,
                    remainingBudget: provider.remainingBudget,
                    onTap: () => onNavigateToTab(2),
                  ),

                  const SizedBox(height: 24),

                  // 4. Checklist Terdekat Yang Perlu Dilakukan
                  SectionHeader(
                    title: 'Checklist Terdekat',
                    subtitle: 'Tugas yang harus diselesaikan',
                    actionText: 'Lihat Semua (${provider.totalChecklistCount})',
                    onAction: () => onNavigateToTab(1),
                  ),
                  const SizedBox(height: 8),

                  if (upcomingChecklist.isEmpty)
                    _buildEmptyBox(
                      'Semua checklist telah selesai! Kerja bagus.',
                      Icons.celebration,
                    )
                  else
                    ...upcomingChecklist.map((item) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          leading: Checkbox(
                            value: item.isDone,
                            activeColor: AppTheme.primaryRose,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (_) => provider.toggleChecklistStatus(item.id),
                          ),
                          title: Text(
                            item.title,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textDark,
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryRoseLight,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.category,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: AppTheme.primaryRoseDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (item.pic.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Text(
                                  'PIC: ${item.pic}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),

                  const SizedBox(height: 24),

                  // 5. Acara Utama Hari H (Rundown Singkat)
                  SectionHeader(
                    title: 'Susunan Acara (Rundown)',
                    subtitle: 'Jadwal hari H pernikahan',
                    actionText: 'Kelola Rundown',
                    onAction: () => onNavigateToTab(4), // Rundown di tab lainnya
                  ),
                  const SizedBox(height: 8),

                  if (provider.rundowns.isEmpty)
                    _buildEmptyBox('Belum ada susunan acara yang dicatat.', Icons.schedule)
                  else
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: provider.rundowns.take(3).map((r) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentGoldLight,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      r.timeRange,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.accentGold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          r.activity,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textDark,
                                          ),
                                        ),
                                        Text(
                                          '${r.eventType} • PIC: ${r.pic.isEmpty ? '-' : r.pic}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: AppTheme.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    required VoidCallback onTap,
    bool isSmallText = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: isSmallText ? 15 : 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: AppTheme.textLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyBox(String text, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.accentGold, size: 28),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  void _showSettingsBottomSheet(BuildContext context, WeddingProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pengaturan Aplikasi',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.edit, color: AppTheme.primaryRose),
                  title: const Text('Ubah Data Mempelai & Anggaran'),
                  onTap: () {
                    Navigator.pop(ctx);
                    showDialog(
                      context: context,
                      builder: (dCtx) => WeddingEditDialog(
                        initialInfo: provider.weddingInfo,
                        onSave: (updated) => provider.updateWeddingInfo(updated),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.palette_outlined, color: AppTheme.infoBlue),
                  title: const Text('Tema Warna Pernikahan'),
                  subtitle: Text(provider.currentTheme.name),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showThemePickerDialog(context, provider);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.refresh, color: AppTheme.warningOrange),
                  title: const Text('Reset ke Data Awal (Template)'),
                  subtitle: const Text('Mengembalikan data contoh default'),
                  onTap: () {
                    Navigator.pop(ctx);
                    showDialog(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: const Text('Reset Data?'),
                        content: const Text(
                          'Data saat ini akan digantikan dengan data template awal.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(c),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
                            onPressed: () {
                              provider.resetToDefault();
                              Navigator.pop(c);
                            },
                            child: const Text('Ya, Reset'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showThemePickerDialog(BuildContext context, WeddingProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pilih Tema Warna',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                Text(
                  'Sesuaikan nuansa aplikasi dengan konsep pernikahan Anda:',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.55,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: WeddingThemePalette.allThemes.length,
                    itemBuilder: (context, index) {
                      final theme = WeddingThemePalette.allThemes[index];
                      final isSelected = provider.currentTheme.id == theme.id;

                      return InkWell(
                        onTap: () {
                          provider.setTheme(theme);
                          Navigator.pop(ctx);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? theme.primaryLight : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? theme.primary : AppTheme.cardBorder,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              // 3 Color Preview Dots
                              Row(
                                children: theme.previewColors.map((color) {
                                  return Container(
                                    margin: const EdgeInsets.only(right: 4),
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 1.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 3,
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      theme.name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        color: isSelected ? theme.primaryDark : AppTheme.textDark,
                                      ),
                                    ),
                                    Text(
                                      theme.subtitle,
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.check_circle, color: theme.primary, size: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
