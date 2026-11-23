import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../providers/wedding_provider.dart';
import '../models/vendor_item.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class VendorScreen extends StatefulWidget {
  const VendorScreen({super.key});

  @override
  State<VendorScreen> createState() => _VendorScreenState();
}

class _VendorScreenState extends State<VendorScreen> {
  String _selectedCategory = 'Semua';

  final List<String> _categories = [
    'Semua',
    'Venue',
    'Katering',
    'Dekorasi',
    'MUA & Busana',
    'Dokumentasi',
    'WO / Planner',
    'Musik & MC',
    'Undangan & Souvenir',
    'Lainnya',
  ];

  final List<String> _statusOptions = [
    'Riset',
    'Diskusi',
    'Booking (DP)',
    'Lunas',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<WeddingProvider>(
      builder: (context, provider, child) {
        var items = provider.vendors;

        if (_selectedCategory != 'Semua') {
          items = items.where((v) => v.category == _selectedCategory).toList();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Daftar Mitra Vendor'),
          ),
          body: Column(
            children: [
              // Category Chips
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                            setState(() => _selectedCategory = cat);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),

              const Divider(height: 1),

              // Vendor List
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.storefront_outlined, size: 48, color: AppTheme.textLight),
                            const SizedBox(height: 12),
                            Text(
                              'Belum ada vendor terdaftar.',
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.name,
                                              style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.textDark,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 6, vertical: 2),
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
                                                const SizedBox(width: 6),
                                                _buildStatusTag(item.status),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert, size: 20),
                                        onSelected: (val) {
                                          if (val == 'edit') {
                                            _showAddEditVendorDialog(context, provider, item: item);
                                          } else if (val == 'delete') {
                                            provider.deleteVendorItem(item.id);
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
                                  const SizedBox(height: 10),

                                  // Contact & Price Details
                                  if (item.contactPerson.isNotEmpty || item.phone.isNotEmpty || item.instagram.isNotEmpty) ...[
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppTheme.backgroundLight,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        children: [
                                          if (item.contactPerson.isNotEmpty || item.phone.isNotEmpty)
                                            Row(
                                              children: [
                                                const Icon(Icons.phone_outlined, size: 14, color: AppTheme.textMuted),
                                                const SizedBox(width: 6),
                                                Text(
                                                  '${item.contactPerson.isNotEmpty ? "${item.contactPerson} " : ""}${item.phone.isNotEmpty ? "(${item.phone})" : ""}',
                                                  style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textDark),
                                                ),
                                              ],
                                            ),
                                          if (item.instagram.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.camera_alt_outlined, size: 14, color: AppTheme.textMuted),
                                                const SizedBox(width: 6),
                                                Text(
                                                  item.instagram,
                                                  style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.infoBlue),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      if (item.cost > 0)
                                        Text(
                                          'Biaya Paket: ${Formatters.currency(item.cost)}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textDark,
                                          ),
                                        )
                                      else
                                        const SizedBox(),
                                    ],
                                  ),

                                  if (item.notes.isNotEmpty) ...[
                                    const SizedBox(height: 4),
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
              'Tambah Vendor',
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            onPressed: () => _showAddEditVendorDialog(context, provider),
          ),
        );
      },
    );
  }

  Widget _buildStatusTag(String status) {
    Color bg;
    Color text;
    if (status == 'Lunas') {
      bg = AppTheme.successGreen.withOpacity(0.15);
      text = AppTheme.successGreen;
    } else if (status.contains('Booking') || status.contains('DP')) {
      bg = AppTheme.warningOrange.withOpacity(0.15);
      text = AppTheme.warningOrange;
    } else {
      bg = Colors.grey.shade200;
      text = AppTheme.textMuted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(
        status,
        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: text),
      ),
    );
  }

  void _showAddEditVendorDialog(BuildContext context, WeddingProvider provider, {VendorItem? item}) {
    final isEditing = item != null;
    final nameController = TextEditingController(text: item?.name ?? '');
    final picController = TextEditingController(text: item?.contactPerson ?? '');
    final phoneController = TextEditingController(text: item?.phone ?? '');
    final igController = TextEditingController(text: item?.instagram ?? '');
    final costController = TextEditingController(text: item != null && item.cost > 0 ? item.cost.toStringAsFixed(0) : '');
    final notesController = TextEditingController(text: item?.notes ?? '');

    String selectedCat = item?.category ?? (_selectedCategory == 'Semua' ? 'Venue' : _selectedCategory);
    String selectedStatus = item?.status ?? 'Riset';

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
                      isEditing ? 'Edit Data Vendor' : 'Tambah Mitra Vendor',
                      style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Vendor / Perusahaan',
                        hintText: 'Misal: Grand Ballroom, MUA Cantika',
                      ),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: selectedCat,
                      decoration: const InputDecoration(labelText: 'Kategori Vendor'),
                      items: _categories
                          .where((c) => c != 'Semua')
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedCat = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: picController,
                            decoration: const InputDecoration(labelText: 'Nama Kontak (PIC)'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(labelText: 'No. Telp / WA'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: igController,
                      decoration: const InputDecoration(
                        labelText: 'Instagram / Website',
                        hintText: '@nama_vendor',
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: costController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Biaya / Harga Paket (Rp)',
                      ),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(labelText: 'Status Negosiasi / Pesanan'),
                      items: _statusOptions
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedStatus = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Catatan & Kelengkapan Kontrak',
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

                            final cost = double.tryParse(costController.text) ?? 0.0;

                            if (isEditing) {
                              provider.updateVendorItem(
                                item.copyWith(
                                  name: nameController.text.trim(),
                                  category: selectedCat,
                                  contactPerson: picController.text.trim(),
                                  phone: phoneController.text.trim(),
                                  instagram: igController.text.trim(),
                                  cost: cost,
                                  status: selectedStatus,
                                  notes: notesController.text.trim(),
                                ),
                              );
                            } else {
                              provider.addVendorItem(
                                VendorItem(
                                  id: const Uuid().v4(),
                                  name: nameController.text.trim(),
                                  category: selectedCat,
                                  contactPerson: picController.text.trim(),
                                  phone: phoneController.text.trim(),
                                  instagram: igController.text.trim(),
                                  cost: cost,
                                  status: selectedStatus,
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
