import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../providers/wedding_provider.dart';
import '../models/guest_item.dart';
import '../theme/app_theme.dart';
import '../services/pdf_service.dart';

class GuestScreen extends StatefulWidget {
  const GuestScreen({super.key});

  @override
  State<GuestScreen> createState() => _GuestScreenState();
}

class _GuestScreenState extends State<GuestScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  String _selectedRsvp = 'Semua';

  final List<String> _categories = [
    'Semua',
    'Keluarga Pria',
    'Keluarga Wanita',
    'Teman Pria',
    'Teman Wanita',
    'Rekan Kerja',
    'VIP',
    'Tetangga',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<WeddingProvider>(
      builder: (context, provider, child) {
        var items = provider.guests;

        // Search Filter
        if (_searchQuery.isNotEmpty) {
          items = items.where((g) {
            return g.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                g.tableNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                g.phoneNumber.contains(_searchQuery);
          }).toList();
        }

        // Category Filter
        if (_selectedCategory != 'Semua') {
          items = items.where((g) => g.category == _selectedCategory).toList();
        }

        // RSVP Filter
        if (_selectedRsvp == 'Hadir') {
          items = items.where((g) => g.rsvpStatus == RsvpStatus.attending).toList();
        } else if (_selectedRsvp == 'Belum Pasti') {
          items = items.where((g) => g.rsvpStatus == RsvpStatus.tentative).toList();
        } else if (_selectedRsvp == 'Tidak Hadir') {
          items = items.where((g) => g.rsvpStatus == RsvpStatus.declined).toList();
        } else if (_selectedRsvp == 'Menunggu') {
          items = items.where((g) => g.rsvpStatus == RsvpStatus.pending).toList();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Daftar Tamu & RSVP'),
            actions: [
              IconButton(
                icon: const Icon(Icons.picture_as_pdf_outlined, color: AppTheme.errorRed),
                tooltip: 'Ekspor PDF',
                onPressed: () async {
                  if (provider.guests.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Belum ada tamu untuk diekspor.')),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal ekspor PDF: $e')),
                    );
                  }
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // 1. Stats Banner
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCol('Total Pax', '${provider.totalGuests}', AppTheme.textDark),
                    _buildDivider(),
                    _buildStatCol('Akan Hadir', '${provider.totalAttendingGuests}', AppTheme.successGreen),
                    _buildDivider(),
                    _buildStatCol(
                      'Undangan Dikirim',
                      '${provider.invitationsSentCount}/${provider.guests.length}',
                      AppTheme.infoBlue,
                    ),
                  ],
                ),
              ),

              // 2. Search Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari nama tamu, nomor meja...',
                    prefixIcon: const Icon(Icons.search, size: 20, color: AppTheme.textLight),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                ),
              ),

              // 3. Category Filter Chips (Horizontal)
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(cat),
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
                            setState(() {
                              _selectedCategory = cat;
                            });
                          }
                        },
                      ),
                    );
                  },
                ),
              ),

              // 4. RSVP Status filter
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    Text(
                      'RSVP: ',
                      style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textMuted),
                    ),
                    const SizedBox(width: 6),
                    _buildRsvpFilterChip('Semua'),
                    const SizedBox(width: 4),
                    _buildRsvpFilterChip('Hadir'),
                    const SizedBox(width: 4),
                    _buildRsvpFilterChip('Menunggu'),
                    const SizedBox(width: 4),
                    _buildRsvpFilterChip('Belum Pasti'),
                  ],
                ),
              ),

              const Divider(height: 1),

              // 5. Guest List
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.people_outline, size: 48, color: AppTheme.textLight),
                            const SizedBox(height: 12),
                            Text(
                              'Tidak ada tamu yang cocok.',
                              style: GoogleFonts.poppins(color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Leading checkbox for Invitation Sent
                                  InkWell(
                                    onTap: () => provider.toggleInvitationSent(item.id),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: item.isInvitationSent
                                            ? AppTheme.primaryRoseLight
                                            : Colors.grey.shade100,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        item.isInvitationSent ? Icons.mark_email_read : Icons.mail_outline,
                                        size: 20,
                                        color: item.isInvitationSent
                                            ? AppTheme.primaryRose
                                            : AppTheme.textLight,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Guest Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item.name,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.textDark,
                                                ),
                                              ),
                                            ),
                                            _buildRsvpBadge(item.rsvpStatus),
                                          ],
                                        ),
                                        const SizedBox(height: 4),

                                        // Category, Pax, Table
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
                                                item.category,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.primaryRoseDark,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                '${item.pax} Pax',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.textDark,
                                                ),
                                              ),
                                            ),
                                            if (item.tableNumber.isNotEmpty)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.accentGoldLight,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  item.tableNumber,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppTheme.accentGold,
                                                  ),
                                                ),
                                              ),
                                            if (item.isInvitationSent)
                                              Text(
                                                '• Undangan Terkirim',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  color: AppTheme.successGreen,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                          ],
                                        ),

                                        if (item.phoneNumber.isNotEmpty || item.notes.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Text(
                                            '${item.phoneNumber.isNotEmpty ? "WA: ${item.phoneNumber}" : ""} ${item.notes.isNotEmpty ? "• ${item.notes}" : ""}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
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
                                        _showAddEditGuestDialog(context, provider, item: item);
                                      } else if (val == 'delete') {
                                        provider.deleteGuestItem(item.id);
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
            icon: const Icon(Icons.person_add, color: Colors.white),
            label: Text(
              'Tambah Tamu',
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            onPressed: () => _showAddEditGuestDialog(context, provider),
          ),
        );
      },
    );
  }

  Widget _buildStatCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textMuted)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 28,
      color: AppTheme.cardBorder,
    );
  }

  Widget _buildRsvpBadge(RsvpStatus status) {
    Color bg;
    Color text;
    String label;
    switch (status) {
      case RsvpStatus.attending:
        bg = AppTheme.successGreen.withOpacity(0.15);
        text = AppTheme.successGreen;
        label = 'Hadir';
        break;
      case RsvpStatus.declined:
        bg = AppTheme.errorRed.withOpacity(0.15);
        text = AppTheme.errorRed;
        label = 'Tidak Hadir';
        break;
      case RsvpStatus.tentative:
        bg = AppTheme.warningOrange.withOpacity(0.15);
        text = AppTheme.warningOrange;
        label = 'Ragu';
        break;
      case RsvpStatus.pending:
        bg = Colors.grey.shade200;
        text = AppTheme.textMuted;
        label = 'Pending';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: text,
        ),
      ),
    );
  }

  Widget _buildRsvpFilterChip(String label) {
    final isSelected = _selectedRsvp == label;
    return InkWell(
      onTap: () => setState(() => _selectedRsvp = label),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryRoseLight : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.primaryRose : AppTheme.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppTheme.primaryRoseDark : AppTheme.textMuted,
          ),
        ),
      ),
    );
  }

  void _showAddEditGuestDialog(BuildContext context, WeddingProvider provider, {GuestItem? item}) {
    final isEditing = item != null;
    final nameController = TextEditingController(text: item?.name ?? '');
    final paxController = TextEditingController(text: item != null ? '${item.pax}' : '1');
    final tableController = TextEditingController(text: item?.tableNumber ?? '');
    final phoneController = TextEditingController(text: item?.phoneNumber ?? '');
    final notesController = TextEditingController(text: item?.notes ?? '');

    String selectedCategory = item?.category ?? (_selectedCategory == 'Semua' ? 'Teman Pria' : _selectedCategory);
    RsvpStatus selectedRsvp = item?.rsvpStatus ?? RsvpStatus.pending;
    bool isInvitationSent = item?.isInvitationSent ?? false;

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
                      isEditing ? 'Edit Data Tamu' : 'Tambah Tamu Undangan',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap / Keluarga',
                        hintText: 'Misal: Dimas Aditya & Pasangan',
                      ),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(labelText: 'Kategori Tamu'),
                      items: _categories
                          .where((c) => c != 'Semua')
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedCategory = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: paxController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Jumlah Pax',
                              hintText: '1 atau 2',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: tableController,
                            decoration: const InputDecoration(
                              labelText: 'Nomor Meja',
                              hintText: 'Misal: Meja 5',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'No. WhatsApp / HP',
                        hintText: '0812xxxxxxx',
                      ),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<RsvpStatus>(
                      value: selectedRsvp,
                      decoration: const InputDecoration(labelText: 'Status RSVP'),
                      items: RsvpStatus.values
                          .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedRsvp = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Undangan Sudah Dikirim',
                        style: GoogleFonts.poppins(fontSize: 13),
                      ),
                      value: isInvitationSent,
                      activeColor: AppTheme.primaryRose,
                      onChanged: (val) {
                        setModalState(() => isInvitationSent = val ?? false);
                      },
                    ),

                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Catatan Tambahan',
                        hintText: 'Alergi makanan, tamu VIP, dll',
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
                            if (nameController.text.trim().isEmpty) return;

                            final pax = int.tryParse(paxController.text) ?? 1;

                            if (isEditing) {
                              provider.updateGuestItem(
                                item.copyWith(
                                  name: nameController.text.trim(),
                                  category: selectedCategory,
                                  pax: pax,
                                  tableNumber: tableController.text.trim(),
                                  phoneNumber: phoneController.text.trim(),
                                  rsvpStatus: selectedRsvp,
                                  isInvitationSent: isInvitationSent,
                                  notes: notesController.text.trim(),
                                ),
                              );
                            } else {
                              provider.addGuestItem(
                                GuestItem(
                                  id: const Uuid().v4(),
                                  name: nameController.text.trim(),
                                  category: selectedCategory,
                                  pax: pax,
                                  tableNumber: tableController.text.trim(),
                                  phoneNumber: phoneController.text.trim(),
                                  rsvpStatus: selectedRsvp,
                                  isInvitationSent: isInvitationSent,
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
