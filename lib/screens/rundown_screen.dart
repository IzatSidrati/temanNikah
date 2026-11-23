import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../providers/wedding_provider.dart';
import '../models/rundown_item.dart';
import '../theme/app_theme.dart';

class RundownScreen extends StatefulWidget {
  const RundownScreen({super.key});

  @override
  State<RundownScreen> createState() => _RundownScreenState();
}

class _RundownScreenState extends State<RundownScreen> {
  String _selectedEvent = 'Semua';

  final List<String> _eventTypes = [
    'Semua',
    'Akad / Pemberkatan',
    'Resepsi',
    'Pra-Nikah',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<WeddingProvider>(
      builder: (context, provider, child) {
        var items = provider.rundowns;

        if (_selectedEvent != 'Semua') {
          items = items.where((r) => r.eventType == _selectedEvent).toList();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Susunan Acara (Rundown)'),
          ),
          body: Column(
            children: [
              // Event Type Filter Chips
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  itemCount: _eventTypes.length,
                  itemBuilder: (context, index) {
                    final type = _eventTypes[index];
                    final isSelected = _selectedEvent == type;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(type),
                        selected: isSelected,
                        selectedColor: AppTheme.primaryRose,
                        labelStyle: GoogleFonts.poppins(
                          color: isSelected ? Colors.white : AppTheme.textDark,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: isSelected ? AppTheme.primaryRose : AppTheme.cardBorder,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedEvent = type);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),

              const Divider(height: 1),

              // Rundown Timeline List
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.schedule, size: 48, color: AppTheme.textLight),
                            const SizedBox(height: 12),
                            Text(
                              'Belum ada susunan acara.',
                              style: GoogleFonts.poppins(color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Time badge on the left
                                  Container(
                                    width: 85,
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentGoldLight,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppTheme.accentGold.withOpacity(0.3)),
                                    ),
                                    child: Column(
                                      children: [
                                        const Icon(Icons.access_time, size: 14, color: AppTheme.accentGold),
                                        const SizedBox(height: 2),
                                        Text(
                                          item.timeRange,
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.accentGold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.activity,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 4),

                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 4,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppTheme.primaryRoseLight,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                item.eventType,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.primaryRoseDark,
                                                ),
                                              ),
                                            ),
                                            if (item.pic.isNotEmpty)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  'PIC: ${item.pic}',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 10,
                                                    color: AppTheme.textDark,
                                                  ),
                                                ),
                                              ),
                                            if (item.location.isNotEmpty)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  item.location,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 10,
                                                    color: AppTheme.textMuted,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),

                                        if (item.notes.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Text(
                                            item.notes,
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              fontStyle: FontStyle.italic,
                                              color: AppTheme.textMuted,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),

                                  // Popup Menu
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, size: 20),
                                    onSelected: (val) {
                                      if (val == 'edit') {
                                        _showAddEditRundownDialog(context, provider, item: item);
                                      } else if (val == 'delete') {
                                        provider.deleteRundownItem(item.id);
                                      }
                                    },
                                    itemBuilder: (ctx) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit, size: 16),
                                            SizedBox(width: 8),
                                            Text('Edit'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, color: AppTheme.errorRed, size: 16),
                                            SizedBox(width: 8),
                                            Text('Hapus', style: TextStyle(color: AppTheme.errorRed)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppTheme.primaryRose,
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              'Tambah Acara',
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            onPressed: () => _showAddEditRundownDialog(context, provider),
          ),
        );
      },
    );
  }

  void _showAddEditRundownDialog(BuildContext context, WeddingProvider provider, {RundownItem? item}) {
    final isEditing = item != null;
    final timeController = TextEditingController(text: item?.timeRange ?? '');
    final activityController = TextEditingController(text: item?.activity ?? '');
    final picController = TextEditingController(text: item?.pic ?? '');
    final locationController = TextEditingController(text: item?.location ?? '');
    final notesController = TextEditingController(text: item?.notes ?? '');

    String selectedEvent = item?.eventType ?? (_selectedEvent == 'Semua' ? 'Resepsi' : _selectedEvent);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing ? 'Edit Jadwal Acara' : 'Tambah Susunan Acara',
                      style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: timeController,
                      decoration: const InputDecoration(
                        labelText: 'Waktu / Jam',
                        hintText: 'Misal: 08:00 - 09:30',
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: activityController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Kegiatan / Acara',
                        hintText: 'Misal: Prosesi Akad Nikah & Doa',
                      ),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: selectedEvent,
                      decoration: const InputDecoration(labelText: 'Bagian Acara'),
                      items: _eventTypes
                          .where((e) => e != 'Semua')
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedEvent = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: picController,
                      decoration: const InputDecoration(
                        labelText: 'Penanggung Jawab (PIC)',
                        hintText: 'Misal: Penghulu, MC, WO',
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Lokasi Spesifik',
                        hintText: 'Misal: Meja Akad, Ruang Rias, Panggung',
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Catatan & Perlengkapan',
                        hintText: 'Siapkan mikrofon, buku nikah, dll',
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Batal'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (activityController.text.trim().isEmpty) return;

                            if (isEditing) {
                              provider.updateRundownItem(
                                item.copyWith(
                                  timeRange: timeController.text.trim(),
                                  activity: activityController.text.trim(),
                                  eventType: selectedEvent,
                                  pic: picController.text.trim(),
                                  location: locationController.text.trim(),
                                  notes: notesController.text.trim(),
                                ),
                              );
                            } else {
                              provider.addRundownItem(
                                RundownItem(
                                  id: const Uuid().v4(),
                                  timeRange: timeController.text.trim(),
                                  activity: activityController.text.trim(),
                                  eventType: selectedEvent,
                                  pic: picController.text.trim(),
                                  location: locationController.text.trim(),
                                  notes: notesController.text.trim(),
                                ),
                              );
                            }
                            Navigator.pop(ctx);
                          },
                          child: Text(isEditing ? 'Simpan' : 'Tambah'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
