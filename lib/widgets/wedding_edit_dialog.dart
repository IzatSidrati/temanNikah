import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/wedding_info.dart';
import '../utils/formatters.dart';

class WeddingEditDialog extends StatefulWidget {
  final WeddingInfo initialInfo;
  final ValueChanged<WeddingInfo> onSave;

  const WeddingEditDialog({
    super.key,
    required this.initialInfo,
    required this.onSave,
  });

  @override
  State<WeddingEditDialog> createState() => _WeddingEditDialogState();
}

class _WeddingEditDialogState extends State<WeddingEditDialog> {
  late TextEditingController _groomController;
  late TextEditingController _brideController;
  late TextEditingController _locationController;
  late TextEditingController _budgetController;
  late TextEditingController _notesController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _groomController = TextEditingController(text: widget.initialInfo.groomName);
    _brideController = TextEditingController(text: widget.initialInfo.brideName);
    _locationController = TextEditingController(text: widget.initialInfo.weddingLocation);
    _budgetController = TextEditingController(
      text: widget.initialInfo.totalBudget.toStringAsFixed(0),
    );
    _notesController = TextEditingController(text: widget.initialInfo.notes);
    _selectedDate = widget.initialInfo.weddingDate;
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryRose,
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pengaturan Data Pernikahan',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _groomController,
                decoration: const InputDecoration(
                  labelText: 'Nama Mempelai Pria',
                  prefixIcon: Icon(Icons.person, color: AppTheme.primaryRose),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _brideController,
                decoration: const InputDecoration(
                  labelText: 'Nama Mempelai Wanita',
                  prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryRose),
                ),
              ),
              const SizedBox(height: 12),

              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.cardBorder),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppTheme.primaryRose, size: 20),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tanggal Pernikahan',
                            style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textMuted),
                          ),
                          Text(
                            Formatters.date(_selectedDate),
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Lokasi / Venue Pernikahan',
                  prefixIcon: Icon(Icons.location_on, color: AppTheme.primaryRose),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Total Anggaran (Rp)',
                  prefixIcon: Icon(Icons.account_balance_wallet, color: AppTheme.primaryRose),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Tema / Catatan Tambahan',
                  prefixIcon: Icon(Icons.note_alt_outlined, color: AppTheme.primaryRose),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Batal',
                      style: GoogleFonts.poppins(color: AppTheme.textMuted),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final updated = widget.initialInfo.copyWith(
                        groomName: _groomController.text.trim(),
                        brideName: _brideController.text.trim(),
                        weddingDate: _selectedDate,
                        weddingLocation: _locationController.text.trim(),
                        totalBudget: double.tryParse(_budgetController.text) ?? widget.initialInfo.totalBudget,
                        notes: _notesController.text.trim(),
                      );
                      widget.onSave(updated);
                      Navigator.pop(context);
                    },
                    child: const Text('Simpan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
