import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../providers/wedding_provider.dart';
import '../models/checklist_item.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  String _selectedCategory = 'Semua';
  String _statusFilter = 'Semua'; // 'Semua', 'Belum Selesai', 'Selesai'

  final List<String> _categories = [
    'Semua',
    'H-12 Bulan',
    'H-6 Bulan',
    'H-3 Bulan',
    'H-1 Bulan',
    'H-1 Minggu',
    'Hari H',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<WeddingProvider>(
      builder: (context, provider, child) {
        var items = provider.checklist;

        // Filter Category
        if (_selectedCategory != 'Semua') {
          items = items.where((c) => c.category == _selectedCategory).toList();
        }

        // Filter Status
        if (_statusFilter == 'Belum Selesai') {
          items = items.where((c) => !c.isDone).toList();
        } else if (_statusFilter == 'Selesai') {
          items = items.where((c) => c.isDone).toList();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Checklist & Timeline'),
          ),
          body: Column(
            children: [
              // 1. Progress Banner
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryRoseLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryRose.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress Persiapan',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryRoseDark,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${provider.completedChecklistCount} dari ${provider.totalChecklistCount} selesai (${(provider.checklistProgress * 100).toInt()}%)',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryRoseDark,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: provider.checklistProgress,
                        minHeight: 8,
                        backgroundColor: Colors.white,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryRose),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Timeline Category Chips (Horizontal scroll)
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

              // 3. Status filter (Semua / Belum / Selesai)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    Text(
                      'Status: ',
                      style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textMuted),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip('Semua'),
                    const SizedBox(width: 6),
                    _buildStatusChip('Belum Selesai'),
                    const SizedBox(width: 6),
                    _buildStatusChip('Selesai'),
                  ],
                ),
              ),

              const Divider(height: 1),

              // 4. Checklist Item List
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.assignment_turned_in_outlined,
                                size: 48, color: AppTheme.textLight),
                            const SizedBox(height: 12),
                            Text(
                              'Tidak ada checklist yang cocok.',
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
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                leading: Checkbox(
                                  value: item.isDone,
                                  activeColor: AppTheme.primaryRose,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  onChanged: (_) {
                                    provider.toggleChecklistStatus(item.id);
                                  },
                                ),
                                title: Text(
                                  item.title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    decoration: item.isDone ? TextDecoration.lineThrough : null,
                                    color: item.isDone ? AppTheme.textLight : AppTheme.textDark,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
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
                                              color: AppTheme.primaryRoseDark,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        if (item.pic.isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'PIC: ${item.pic}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                color: AppTheme.textMuted,
                                              ),
                                            ),
                                          ),
                                        if (item.dueDate != null)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'Target: ${Formatters.dateShort(item.dueDate)}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                color: AppTheme.textMuted,
                                              ),
                                            ),
                                          ),
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
                                trailing: PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert, size: 20),
                                  onSelected: (val) {
                                    if (val == 'edit') {
                                      _showAddEditDialog(context, provider, item: item);
                                    } else if (val == 'delete') {
                                      provider.deleteChecklistItem(item.id);
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
              'Tambah Tugas',
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            onPressed: () => _showAddEditDialog(context, provider),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    final isSelected = _statusFilter == status;
    return InkWell(
      onTap: () {
        setState(() {
          _statusFilter = status;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryRoseLight : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryRose : AppTheme.cardBorder,
          ),
        ),
        child: Text(
          status,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppTheme.primaryRoseDark : AppTheme.textMuted,
          ),
        ),
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, WeddingProvider provider, {ChecklistItem? item}) {
    final isEditing = item != null;
    final titleController = TextEditingController(text: item?.title ?? '');
    final picController = TextEditingController(text: item?.pic ?? '');
    final notesController = TextEditingController(text: item?.notes ?? '');
    String selectedCat = item?.category ?? (_selectedCategory == 'Semua' ? 'H-6 Bulan' : _selectedCategory);
    DateTime? selectedDate = item?.dueDate;

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
                      isEditing ? 'Edit Checklist' : 'Tambah Checklist Baru',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi Tugas / Item',
                        hintText: 'Misal: Booking katering atau urus berkas KUA',
                      ),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: selectedCat,
                      decoration: const InputDecoration(labelText: 'Timeline / Periode'),
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

                    TextField(
                      controller: picController,
                      decoration: const InputDecoration(
                        labelText: 'Penanggung Jawab (PIC)',
                        hintText: 'Misal: Sarah, Rian, atau WO',
                      ),
                    ),
                    const SizedBox(height: 12),

                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(const Duration(days: 30)),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                        );
                        if (picked != null) {
                          setModalState(() => selectedDate = picked);
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.cardBorder),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedDate == null
                                  ? 'Pilih Target Tanggal (Opsional)'
                                  : 'Target: ${Formatters.date(selectedDate)}',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: selectedDate == null ? AppTheme.textLight : AppTheme.textDark,
                              ),
                            ),
                            const Icon(Icons.calendar_today, size: 18, color: AppTheme.primaryRose),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Catatan Tambahan',
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
                            if (titleController.text.trim().isEmpty) return;

                            if (isEditing) {
                              provider.updateChecklistItem(
                                item.copyWith(
                                  title: titleController.text.trim(),
                                  category: selectedCat,
                                  pic: picController.text.trim(),
                                  dueDate: selectedDate,
                                  notes: notesController.text.trim(),
                                ),
                              );
                            } else {
                              provider.addChecklistItem(
                                ChecklistItem(
                                  id: const Uuid().v4(),
                                  title: titleController.text.trim(),
                                  category: selectedCat,
                                  pic: picController.text.trim(),
                                  dueDate: selectedDate,
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
