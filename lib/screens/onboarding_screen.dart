import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/wedding_provider.dart';
import '../models/wedding_info.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'main_navigation_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final bool isEditingFromSettings;

  const OnboardingScreen({
    super.key,
    this.isEditingFromSettings = false,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _groomController;
  late TextEditingController _brideController;
  late TextEditingController _locationController;
  late TextEditingController _budgetController;
  late TextEditingController _notesController;

  late DateTime _selectedDate;
  late WeddingThemePalette _selectedTheme;
  bool _useDefaultChecklist = true;
  bool _isSaving = false;

  final List<double> _budgetPresets = [
    50000000,
    100000000,
    150000000,
    200000000,
    300000000,
  ];

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<WeddingProvider>(context, listen: false);
    final initial = provider.weddingInfo;

    // Jika sedang edit dari settings, gunakan data yang ada. Jika baru install, kosongkan form agar user bisa isi sendiri.
    if (widget.isEditingFromSettings) {
      _groomController = TextEditingController(text: initial.groomName);
      _brideController = TextEditingController(text: initial.brideName);
      _locationController = TextEditingController(text: initial.weddingLocation);
      _budgetController = TextEditingController(text: initial.totalBudget.toStringAsFixed(0));
      _notesController = TextEditingController(text: initial.notes);
      _selectedDate = initial.weddingDate;
    } else {
      _groomController = TextEditingController();
      _brideController = TextEditingController();
      _locationController = TextEditingController();
      _budgetController = TextEditingController(text: '150000000');
      _notesController = TextEditingController();
      _selectedDate = DateTime.now().add(const Duration(days: 180));
    }

    _selectedTheme = provider.currentTheme;
  }

  @override
  void dispose() {
    _groomController.dispose();
    _brideController.dispose();
    _locationController.dispose();
    _budgetController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      helpText: 'PILIH TANGGAL PERNIKAHAN',
      cancelText: 'BATAL',
      confirmText: 'PILIH',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _selectedTheme.primary,
              onPrimary: Colors.white,
              onSurface: AppTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final budget = double.tryParse(_budgetController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 150000000.0;

    final newInfo = WeddingInfo(
      groomName: _groomController.text.trim(),
      brideName: _brideController.text.trim(),
      weddingDate: _selectedDate,
      weddingLocation: _locationController.text.trim().isEmpty 
          ? 'Indonesia' 
          : _locationController.text.trim(),
      totalBudget: budget,
      notes: _notesController.text.trim(),
    );

    final provider = Provider.of<WeddingProvider>(context, listen: false);

    if (widget.isEditingFromSettings) {
      provider.updateWeddingInfo(newInfo);
      provider.setTheme(_selectedTheme);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data master pernikahan berhasil diperbarui!'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } else {
      await provider.completeOnboarding(
        info: newInfo,
        useDefaultChecklist: _useDefaultChecklist,
        theme: _selectedTheme,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final diff = _selectedDate.difference(DateTime.now());
    final daysRemaining = diff.isNegative ? 0 : diff.inDays;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Banner
                _buildHeaderCard(),
                const SizedBox(height: 24),

                // Form Bagian 1: Data Pasangan
                _buildSectionTitle('1. Data Mempelai Pengantin', Icons.favorite_rounded),
                const SizedBox(height: 12),
                _buildGroomBrideCard(),
                const SizedBox(height: 20),

                // Form Bagian 2: Tanggal & Lokasi
                _buildSectionTitle('2. Waktu & Lokasi Acara', Icons.event_available_rounded),
                const SizedBox(height: 12),
                _buildDateAndLocationCard(daysRemaining),
                const SizedBox(height: 20),

                // Form Bagian 3: Target Anggaran (Budget)
                _buildSectionTitle('3. Rencana Anggaran Pernikahan', Icons.account_balance_wallet_rounded),
                const SizedBox(height: 12),
                _buildBudgetCard(),
                const SizedBox(height: 20),

                // Form Bagian 4: Nuansa & Tema Warna Aplikasi
                _buildSectionTitle('4. Nuansa Warna Aplikasi Favorit', Icons.palette_rounded),
                const SizedBox(height: 12),
                _buildThemeSelector(),
                const SizedBox(height: 20),

                // Form Bagian 5: Checklist Template (Hanya saat onboarding awal)
                if (!widget.isEditingFromSettings) ...[
                  _buildSectionTitle('5. Rekomendasi Persiapan', Icons.checklist_rounded),
                  const SizedBox(height: 12),
                  _buildChecklistOptionCard(),
                  const SizedBox(height: 24),
                ],

                // Tombol Simpan & Selesai
                _buildSubmitButton(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _selectedTheme.primaryLight,
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _selectedTheme.primary.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _selectedTheme.primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _selectedTheme.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_rounded,
              color: _selectedTheme.primary,
              size: 36,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.isEditingFromSettings
                ? 'Ubah Data Master Pernikahan'
                : 'Selamat Datang di Teman Nikah',
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.isEditingFromSettings
                ? 'Perbarui informasi dasar pernikahan Anda kapan saja.'
                : 'Langkah awal mempersiapkan hari bahagia Anda dan pasangan agar terencana rapi & menyenangkan.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppTheme.textMuted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _selectedTheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildGroomBrideCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
        children: [
          TextFormField(
            controller: _groomController,
            decoration: InputDecoration(
              labelText: 'Nama Pengantin Pria',
              hintText: 'contoh: Rian Pratama',
              prefixIcon: Icon(Icons.person, color: _selectedTheme.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: AppTheme.backgroundLight.withOpacity(0.5),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nama pengantin pria wajib diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _brideController,
            decoration: InputDecoration(
              labelText: 'Nama Pengantin Wanita',
              hintText: 'contoh: Sarah Amanda',
              prefixIcon: Icon(Icons.person_outline, color: _selectedTheme.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: AppTheme.backgroundLight.withOpacity(0.5),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nama pengantin wanita wajib diisi';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateAndLocationCard(int daysRemaining) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          Text(
            'Hari Bahagia (Tanggal Pernikahan):',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _selectedTheme.primaryLight.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _selectedTheme.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_month_rounded, color: _selectedTheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Formatters.date(_selectedDate),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          daysRemaining == 0
                              ? 'Hari H adalah hari ini!'
                              : '$daysRemaining hari lagi menuju hari pernikahan',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: _selectedTheme.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _selectedTheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Ubah',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: 'Lokasi / Venue Acara',
              hintText: 'contoh: Grand Ballroom Hotel Mulia, Jakarta',
              prefixIcon: Icon(Icons.location_on_outlined, color: _selectedTheme.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: AppTheme.backgroundLight.withOpacity(0.5),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Lokasi acara wajib diisi';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard() {
    double currentBudget = double.tryParse(_budgetController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          TextFormField(
            controller: _budgetController,
            keyboardType: TextInputType.number,
            onChanged: (val) {
              setState(() {});
            },
            decoration: InputDecoration(
              labelText: 'Target Total Anggaran (Rupiah)',
              hintText: '150000000',
              prefixIcon: Icon(Icons.account_balance_wallet_outlined, color: _selectedTheme.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: AppTheme.backgroundLight.withOpacity(0.5),
              helperText: currentBudget > 0
                  ? 'Terformat: ${Formatters.currency(currentBudget)}'
                  : null,
              helperStyle: GoogleFonts.poppins(
                color: _selectedTheme.primaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Anggaran wajib diisi';
              }
              final valNum = double.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
              if (valNum == null || valNum <= 0) {
                return 'Masukkan nominal anggaran yang valid';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          Text(
            'Pilihan Cepat:',
            style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _budgetPresets.map((preset) {
              final isSelected = currentBudget == preset;
              return ChoiceChip(
                label: Text('${(preset / 1000000).toStringAsFixed(0)} Juta'),
                selected: isSelected,
                selectedColor: _selectedTheme.primary,
                labelStyle: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : AppTheme.textDark,
                ),
                backgroundColor: AppTheme.backgroundLight,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _budgetController.text = preset.toStringAsFixed(0);
                    });
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _notesController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Konsep Acara / Catatan Impian (Opsional)',
              hintText: 'contoh: Nuansa Modern Rustic, intimate wedding keluarga & sahabat.',
              prefixIcon: Icon(Icons.auto_awesome_outlined, color: _selectedTheme.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: AppTheme.backgroundLight.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
        children: WeddingThemePalette.allThemes.map((theme) {
          final isSelected = _selectedTheme.id == theme.id;
          return InkWell(
            onTap: () {
              setState(() {
                _selectedTheme = theme;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? theme.primaryLight : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? theme.primary : AppTheme.cardBorder,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
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
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          theme.name,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? theme.primaryDark : AppTheme.textDark,
                          ),
                        ),
                        Text(
                          theme.subtitle,
                          style: GoogleFonts.poppins(fontSize: 10, color: AppTheme.textMuted),
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
        }).toList(),
      ),
    );
  }

  Widget _buildChecklistOptionCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SwitchListTile(
        value: _useDefaultChecklist,
        activeColor: _selectedTheme.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        title: Text(
          'Muat Rekomendasi Checklist Otomatis',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        subtitle: Text(
          'Menyertakan 20+ daftar persiapan penting mulai dari H-12 bulan hingga Hari H yang bisa langsung Anda gunakan & sesuaikan.',
          style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textMuted),
        ),
        onChanged: (val) {
          setState(() {
            _useDefaultChecklist = val;
          });
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedTheme.primary,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: _selectedTheme.primary.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.isEditingFromSettings
                        ? 'Simpan Perubahan'
                        : 'Mulai Rencanakan Pernikahan ✨',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
