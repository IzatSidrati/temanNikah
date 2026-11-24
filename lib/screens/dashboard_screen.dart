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
import '../services/notification_service.dart';
import '../services/backup_service.dart';
import '../services/pdf_service.dart';
import '../services/ad_service.dart';
import '../widgets/ad_native_widget.dart';
import 'onboarding_screen.dart';

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
        final palette = provider.currentTheme;
        final upcomingChecklist = provider.checklist.where((c) => !c.isDone).take(3).toList();

        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.favorite, color: palette.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Teman Nikah',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
            actions: [
              ValueListenableBuilder<bool>(
                valueListenable: AdService().isAdFreeNotifier,
                builder: (context, isAdFree, _) {
                  return IconButton(
                    icon: Icon(
                      isAdFree ? Icons.workspace_premium : Icons.card_giftcard_outlined,
                      color: isAdFree ? AppTheme.accentGold : palette.primary,
                    ),
                    tooltip: isAdFree ? 'Mode Bebas Iklan Aktif' : 'Bebas Iklan 30 Menit',
                    onPressed: () => _showRewardedAdDialog(context, palette),
                  );
                },
              ),
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
            color: palette.primary,
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

                  // 3b. Native Ad Card (otomatis tersembunyi jika mode Bebas Iklan aktif)
                  AdNativeWidget(accentColor: palette.primary),

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
                            activeColor: palette.primary,
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
                                  color: palette.primaryLight,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.category,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: palette.primaryDark,
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.cardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Pengaturan Aplikasi',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),

                // ── BAGIAN: Data Pernikahan ──────────────────────
                _sectionLabel('Data Pernikahan'),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.app_registration_rounded, color: AppTheme.primaryRose),
                  title: const Text('Form Data Master Pernikahan'),
                  subtitle: const Text('Ubah nama, tanggal, lokasi & tema'),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OnboardingScreen(isEditingFromSettings: true),
                      ),
                    );
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.palette_outlined, color: AppTheme.infoBlue),
                  title: const Text('Tema Warna Pernikahan'),
                  subtitle: Text(provider.currentTheme.name),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showThemePickerDialog(context, provider);
                  },
                ),

                const Divider(),

                // ── BAGIAN: Ekspor PDF ───────────────────────────
                _sectionLabel('Ekspor ke PDF'),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.people_alt_outlined, color: AppTheme.infoBlue),
                  title: const Text('Ekspor Daftar Tamu (PDF)'),
                  subtitle: Text('${provider.guests.length} tamu • ${provider.totalGuests} pax'),
                  trailing: const Icon(Icons.picture_as_pdf_outlined, color: AppTheme.errorRed),
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(ctx);
                    if (provider.guests.isEmpty) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Belum ada data tamu yang bisa diekspor.')),
                      );
                      return;
                    }
                    try {
                      await PdfService().exportGuestListPdf(
                        context: context,
                        info: provider.weddingInfo,
                        guests: provider.guests,
                      );
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(content: Text('Gagal ekspor PDF: $e')),
                      );
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.schedule, color: AppTheme.accentGold),
                  title: const Text('Ekspor Rundown Acara (PDF)'),
                  subtitle: Text('${provider.rundowns.length} agenda acara'),
                  trailing: const Icon(Icons.picture_as_pdf_outlined, color: AppTheme.errorRed),
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(ctx);
                    if (provider.rundowns.isEmpty) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Belum ada rundown yang bisa diekspor.')),
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
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.savings_outlined, color: AppTheme.successGreen),
                  title: const Text('Ekspor Ringkasan Anggaran (PDF)'),
                  subtitle: Text('${provider.expenses.length} item pengeluaran'),
                  trailing: const Icon(Icons.picture_as_pdf_outlined, color: AppTheme.errorRed),
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(ctx);
                    try {
                      await PdfService().exportBudgetPdf(
                        context: context,
                        info: provider.weddingInfo,
                        expenses: provider.expenses,
                        totalBudget: provider.totalBudget,
                      );
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(content: Text('Gagal ekspor PDF: $e')),
                      );
                    }
                  },
                ),

                const Divider(),

                // ── BAGIAN: Notifikasi ───────────────────────────
                _sectionLabel('Notifikasi'),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.notifications_active_outlined, color: AppTheme.warningOrange),
                  title: const Text('Aktifkan Pengingat Hari-H'),
                  subtitle: const Text('Notifikasi otomatis H-30, H-14, H-7, H-3, H-1, Hari-H'),
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(ctx);
                    final service = NotificationService();
                    final granted = await service.requestPermission();
                    if (!granted) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Izin notifikasi ditolak. Aktifkan di Pengaturan HP.'),
                          backgroundColor: AppTheme.errorRed,
                        ),
                      );
                      return;
                    }
                    final count = await service.scheduleWeddingReminders(provider.weddingInfo.weddingDate);
                    await service.showTestNotification();
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('✅ $count notifikasi pengingat hari-H berhasil dijadwalkan!'),
                        backgroundColor: AppTheme.successGreen,
                      ),
                    );
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.notifications_off_outlined, color: AppTheme.textMuted),
                  title: const Text('Matikan Semua Notifikasi'),
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(ctx);
                    await NotificationService().cancelAllReminders();
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Semua notifikasi pengingat dimatikan.')),
                    );
                  },
                ),

                const Divider(),

                // ── BAGIAN: Backup & Restore ─────────────────────
                _sectionLabel('Backup & Restore'),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.backup_outlined, color: AppTheme.infoBlue),
                  title: const Text('Ekspor Backup Data'),
                  subtitle: const Text('Simpan semua data ke file JSON'),
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(ctx);
                    final success = await BackupService().exportBackup(context);
                    if (success) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('✅ Backup data berhasil diekspor!'),
                          backgroundColor: AppTheme.successGreen,
                        ),
                      );
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.restore_outlined, color: AppTheme.warningOrange),
                  title: const Text('Pulihkan dari Backup'),
                  subtitle: const Text('Tempel isi file JSON backup untuk memulihkan'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showRestoreDialog(context, provider);
                  },
                ),

                const Divider(),

                // ── BAGIAN: Iklan & Mode Bebas Iklan (AdMob) ─────
                _sectionLabel(
                  AdService.useTestAds ? 'Iklan AdMob (Mode Debug / Test)' : 'Mode Bebas Iklan',
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.workspace_premium_outlined, color: AppTheme.accentGold),
                  title: const Text('Bebas Iklan 30 Menit'),
                  subtitle: Text(
                    AdService().isAdFree
                        ? 'Aktif — sisa ${AdService().remainingAdFreeMinutes} menit'
                        : 'Tonton video singkat untuk sembunyikan semua iklan',
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showRewardedAdDialog(context, provider.currentTheme);
                  },
                ),
                if (AdService.useTestAds)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.ad_units_outlined, color: AppTheme.infoBlue),
                    title: const Text('Tampilkan Iklan Interstitial (Debug)'),
                    subtitle: Text(
                      AdService().isInterstitialReady
                          ? 'Siap ditampilkan (Test Ad)'
                          : 'Sedang memuat iklan...',
                    ),
                    onTap: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      Navigator.pop(ctx);
                      final shown = await AdService().showInterstitialAd(force: true);
                      if (!shown) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Iklan Interstitial sedang dimuat, coba beberapa detik lagi.'),
                          ),
                        );
                      }
                    },
                  ),
                if (AdService.useTestAds && AdService().isAdFree)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.visibility_outlined, color: AppTheme.textMuted),
                    title: const Text('Tampilkan Kembali Iklan (Reset Test)'),
                    subtitle: const Text('Matikan mode bebas iklan untuk uji coba Banner & Native'),
                    onTap: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      Navigator.pop(ctx);
                      await AdService().clearAdFreeForTesting();
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Mode bebas iklan dimatikan, iklan aktif kembali.')),
                      );
                    },
                  ),

                const Divider(),

                // ── BAGIAN: Reset ────────────────────────────────
                _sectionLabel('Reset'),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.restart_alt_rounded, color: AppTheme.warningOrange),
                  title: const Text('Ulangi Setup Awal (Onboarding)'),
                  subtitle: const Text('Kembali ke form pertama kali install'),
                  onTap: () {
                    Navigator.pop(ctx);
                    showDialog(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: const Text('Mulai Ulang Setup?'),
                        content: const Text(
                          'Aplikasi akan kembali menampilkan form master data seperti saat pertama kali diinstal.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(c),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warningOrange),
                            onPressed: () {
                              Navigator.pop(c);
                              provider.resetToOnboarding();
                            },
                            child: const Text('Ya, Buka Form Awal'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.refresh, color: AppTheme.errorRed),
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
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4, left: 2),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppTheme.textMuted,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  void _showRewardedAdDialog(BuildContext context, WeddingThemePalette palette) {
    final adService = AdService();
    final isAdFree = adService.isAdFree;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isAdFree ? Icons.workspace_premium : Icons.card_giftcard_rounded,
              color: isAdFree ? AppTheme.accentGold : palette.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isAdFree ? 'Bebas Iklan Aktif' : 'Bebas Iklan 30 Menit',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          isAdFree
              ? 'Mode bebas iklan sedang aktif selama ${adService.remainingAdFreeMinutes} menit lagi. Anda dapat menonton video lagi untuk memperpanjang 30 menit.'
              : 'Tonton 1 video iklan singkat (Rewarded Ad) untuk menyembunyikan Banner, Native, dan Interstitial Ad selama 30 menit penuh.',
          style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: palette.primary),
            icon: const Icon(Icons.play_circle_outline, size: 18),
            label: const Text('Tonton Video'),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              await adService.showRewardedAd(
                onRewardEarned: (reward) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('🎉 Selamat! Mode Bebas Iklan aktif selama 30 menit.'),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                },
                onAdNotReady: () {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Video Rewarded Ad sedang dimuat, silakan coba beberapa detik lagi.'),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog(BuildContext context, WeddingProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Pulihkan dari Backup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tempel isi file JSON backup di bawah ini.\nSemua data saat ini akan digantikan.',
              style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Paste isi file .json di sini...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warningOrange),
            onPressed: () async {
              final json = controller.text.trim();
              if (json.isEmpty) return;
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              final result = await BackupService().importBackup(json);
              if (result.success) {
                await provider.loadData();
              }
              messenger.showSnackBar(
                SnackBar(
                  content: Text(result.message),
                  backgroundColor: result.success ? AppTheme.successGreen : AppTheme.errorRed,
                ),
              );
            },
            child: const Text('Pulihkan Data'),
          ),
        ],
      ),
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
