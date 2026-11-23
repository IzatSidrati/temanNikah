import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../providers/wedding_provider.dart';
import '../models/expense_item.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  String _selectedCategory = 'Semua';
  String _selectedPaymentStatus = 'Semua';

  final List<String> _categories = [
    'Semua',
    'Venue & Dekorasi',
    'Katering',
    'Busana & MUA',
    'Foto & Video',
    'Undangan & Souvenir',
    'Mahar & Seserahan',
    'Lainnya',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<WeddingProvider>(
      builder: (context, provider, child) {
        var items = provider.expenses;

        // Filter Category
        if (_selectedCategory != 'Semua') {
          items = items.where((e) => e.category == _selectedCategory).toList();
        }

        // Filter Payment Status
        if (_selectedPaymentStatus == 'Lunas') {
          items = items.where((e) => e.status == PaymentStatus.paid).toList();
        } else if (_selectedPaymentStatus == 'DP') {
          items = items.where((e) => e.status == PaymentStatus.downPayment).toList();
        } else if (_selectedPaymentStatus == 'Belum Bayar') {
          items = items.where((e) => e.status == PaymentStatus.unpaid).toList();
        }

        final isOverBudget = provider.totalActualExpense > provider.totalBudget;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Anggaran & Pengeluaran'),
          ),
          body: Column(
            children: [
              // 1. Budget Overview Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Pengeluaran Riil',
                              style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textMuted),
                            ),
                            Text(
                              Formatters.currency(provider.totalActualExpense),
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isOverBudget ? AppTheme.errorRed : AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Total Budget',
                              style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textMuted),
                            ),
                            Text(
                              Formatters.currency(provider.totalBudget),
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: provider.budgetProgressPercentage,
                        minHeight: 8,
                        backgroundColor: AppTheme.cardBorder,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isOverBudget ? AppTheme.errorRed : AppTheme.primaryRose,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSummaryItem(
                          'Total Terbayar',
                          Formatters.currency(provider.totalPaidExpense),
                          AppTheme.successGreen,
                        ),
                        _buildSummaryItem(
                          isOverBudget ? 'Defisit Budget' : 'Sisa Alokasi',
                          Formatters.currency(provider.remainingBudget.abs()),
                          isOverBudget ? AppTheme.errorRed : AppTheme.accentGold,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 2. Filter Kategori (Horizontal)
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

              // 3. Filter Status Pembayaran
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    Text(
                      'Status: ',
                      style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textMuted),
                    ),
                    const SizedBox(width: 8),
                    _buildPaymentStatusChip('Semua'),
                    const SizedBox(width: 6),
                    _buildPaymentStatusChip('Belum Bayar'),
                    const SizedBox(width: 6),
                    _buildPaymentStatusChip('DP'),
                    const SizedBox(width: 6),
                    _buildPaymentStatusChip('Lunas'),
                  ],
                ),
              ),

              const Divider(height: 1),

              // 4. Expenses List
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.receipt_long_outlined,
                                size: 48, color: AppTheme.textLight),
                            const SizedBox(height: 12),
                            Text(
                              'Tidak ada pencatatan pengeluaran yang cocok.',
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
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Top Row: Title, Category, Status Badge
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.title,
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: AppTheme.textDark,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              item.category,
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                color: AppTheme.textMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      _buildStatusBadge(item.status),
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert, size: 20),
                                        padding: EdgeInsets.zero,
                                        onSelected: (val) {
                                          if (val == 'edit') {
                                            _showAddEditExpenseDialog(context, provider, item: item);
                                          } else if (val == 'delete') {
                                            provider.deleteExpenseItem(item.id);
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
                                  const SizedBox(height: 12),

                                  // Financial Details (Cost, Paid, Remaining)
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppTheme.backgroundLight,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildPriceColumn(
                                          'Biaya Riil',
                                          Formatters.currency(item.actualCost > 0 ? item.actualCost : item.estimatedCost),
                                          AppTheme.textDark,
                                        ),
                                        _buildPriceColumn(
                                          'Terbayar',
                                          Formatters.currency(item.paidAmount),
                                          AppTheme.successGreen,
                                        ),
                                        _buildPriceColumn(
                                          'Sisa Tagihan',
                                          Formatters.currency(item.remainingAmount),
                                          item.remainingAmount > 0 ? AppTheme.warningOrange : AppTheme.textLight,
                                        ),
                                      ],
                                    ),
                                  ),

                                  if (item.notes.isNotEmpty) ...[
                                    const SizedBox(height: 8),
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
              'Catat Pengeluaran',
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            onPressed: () => _showAddEditExpenseDialog(context, provider),
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textMuted)),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }

  Widget _buildPriceColumn(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 10, color: AppTheme.textMuted)),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(PaymentStatus status) {
    Color bg;
    Color text;
    switch (status) {
      case PaymentStatus.paid:
        bg = AppTheme.successGreen.withOpacity(0.15);
        text = AppTheme.successGreen;
        break;
      case PaymentStatus.downPayment:
        bg = AppTheme.warningOrange.withOpacity(0.15);
        text = AppTheme.warningOrange;
        break;
      case PaymentStatus.unpaid:
        bg = AppTheme.errorRed.withOpacity(0.15);
        text = AppTheme.errorRed;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.shortLabel,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: text,
        ),
      ),
    );
  }

  Widget _buildPaymentStatusChip(String status) {
    final isSelected = _selectedPaymentStatus == status;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentStatus = status;
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

  void _showAddEditExpenseDialog(BuildContext context, WeddingProvider provider, {ExpenseItem? item}) {
    final isEditing = item != null;
    final titleController = TextEditingController(text: item?.title ?? '');
    final estimatedController = TextEditingController(
      text: item != null ? item.estimatedCost.toStringAsFixed(0) : '',
    );
    final actualController = TextEditingController(
      text: item != null && item.actualCost > 0 ? item.actualCost.toStringAsFixed(0) : '',
    );
    final paidController = TextEditingController(
      text: item != null && item.paidAmount > 0 ? item.paidAmount.toStringAsFixed(0) : '',
    );
    final notesController = TextEditingController(text: item?.notes ?? '');

    String selectedCategory = item?.category ?? (_selectedCategory == 'Semua' ? 'Venue & Dekorasi' : _selectedCategory);
    PaymentStatus selectedStatus = item?.status ?? PaymentStatus.unpaid;

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
                      isEditing ? 'Edit Pengeluaran' : 'Catat Pengeluaran Baru',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Pos Pengeluaran',
                        hintText: 'Misal: Katering, Dekorasi, atau Souvenir',
                      ),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(labelText: 'Kategori'),
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

                    TextField(
                      controller: estimatedController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Estimasi Biaya (Rp)',
                        hintText: 'Perkiraan budget awal',
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: actualController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Biaya Riil / Tagihan Akhir (Rp)',
                        hintText: 'Total harga yang disepakati',
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: paidController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Nominal Yang Sudah Dibayar (Rp)',
                        hintText: 'Jumlah DP atau pelunasan',
                      ),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<PaymentStatus>(
                      value: selectedStatus,
                      decoration: const InputDecoration(labelText: 'Status Pembayaran'),
                      items: PaymentStatus.values
                          .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
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
                        labelText: 'Catatan Tambahan',
                        hintText: 'Jatuh tempo pelunasan, no invoice, dll',
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

                            final est = double.tryParse(estimatedController.text) ?? 0.0;
                            final act = double.tryParse(actualController.text) ?? est;
                            final paid = double.tryParse(paidController.text) ?? 0.0;

                            if (isEditing) {
                              provider.updateExpenseItem(
                                item.copyWith(
                                  title: titleController.text.trim(),
                                  category: selectedCategory,
                                  estimatedCost: est,
                                  actualCost: act,
                                  paidAmount: paid,
                                  status: selectedStatus,
                                  notes: notesController.text.trim(),
                                ),
                              );
                            } else {
                              provider.addExpenseItem(
                                ExpenseItem(
                                  id: const Uuid().v4(),
                                  title: titleController.text.trim(),
                                  category: selectedCategory,
                                  estimatedCost: est,
                                  actualCost: act,
                                  paidAmount: paid,
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
