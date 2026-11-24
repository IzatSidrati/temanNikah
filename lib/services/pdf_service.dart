import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/guest_item.dart';
import '../models/rundown_item.dart';
import '../models/expense_item.dart';
import '../models/wedding_info.dart';

class PdfService {
  static final PdfService _instance = PdfService._internal();
  factory PdfService() => _instance;
  PdfService._internal();

  // Warna tema rose gold
  static const _primaryColor = PdfColor.fromInt(0xFFC88289);
  static const _accentColor = PdfColor.fromInt(0xFFD4AF37);
  static const _textDark = PdfColor.fromInt(0xFF2C2526);
  static const _textMuted = PdfColor.fromInt(0xFF7A6F71);
  static const _bgLight = PdfColor.fromInt(0xFFFBF9F9);
  static const _successGreen = PdfColor.fromInt(0xFF48A868);
  static const _errorRed = PdfColor.fromInt(0xFFD9534F);
  static const _warningOrange = PdfColor.fromInt(0xFFE58F3B);

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '-';
    return DateFormat('d MMMM yyyy', 'id_ID').format(d);
  }

  /// Export daftar tamu ke PDF + share
  Future<void> exportGuestListPdf({
    required BuildContext context,
    required WeddingInfo info,
    required List<GuestItem> guests,
  }) async {
    final doc = pw.Document();

    // Sort guests by category
    final sortedGuests = List<GuestItem>.from(guests)
      ..sort((a, b) => a.category.compareTo(b.category));

    // Group by category
    final grouped = <String, List<GuestItem>>{};
    for (final g in sortedGuests) {
      grouped.putIfAbsent(g.category, () => []).add(g);
    }

    final totalPax = guests.fold(0, (sum, g) => sum + g.pax);
    final attending = guests.where((g) => g.rsvpStatus == RsvpStatus.attending).fold(0, (s, g) => s + g.pax);
    final sent = guests.where((g) => g.isInvitationSent).length;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (ctx) => _buildHeader(info, 'Daftar Tamu Undangan'),
        footer: (ctx) => _buildFooter(ctx),
        build: (ctx) => [
          // Stats
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: _bgLight,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: _primaryColor.shade(0.3)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _statBox('Total Tamu', '${guests.length} nama'),
                _statBox('Total Pax', '$totalPax orang'),
                _statBox('Konfirmasi Hadir', '$attending pax'),
                _statBox('Undangan Terkirim', '$sent/${guests.length}'),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Per category
          ...grouped.entries.map((entry) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: pw.BoxDecoration(
                    color: _primaryColor,
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Text(
                    '${entry.key}  (${entry.value.length} nama)',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColor.fromInt(0xFFEFE8E8), width: 0.5),
                  columnWidths: {
                    0: const pw.FixedColumnWidth(28),
                    1: const pw.FlexColumnWidth(3),
                    2: const pw.FlexColumnWidth(1.5),
                    3: const pw.FlexColumnWidth(1.5),
                    4: const pw.FlexColumnWidth(1.5),
                    5: const pw.FlexColumnWidth(2),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF9EEF0)),
                      children: [
                        _tableHeader('No'),
                        _tableHeader('Nama'),
                        _tableHeader('Pax'),
                        _tableHeader('Meja'),
                        _tableHeader('RSVP'),
                        _tableHeader('Undangan'),
                      ],
                    ),
                    ...entry.value.asMap().entries.map((e) {
                      final i = e.key;
                      final g = e.value;
                      return pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: i.isEven ? PdfColors.white : PdfColor.fromInt(0xFFFBF9F9),
                        ),
                        children: [
                          _tableCell('${i + 1}', align: pw.TextAlign.center),
                          _tableCell(g.name),
                          _tableCell('${g.pax}', align: pw.TextAlign.center),
                          _tableCell(g.tableNumber.isEmpty ? '-' : g.tableNumber, align: pw.TextAlign.center),
                          _tableCellColored(_rsvpLabel(g.rsvpStatus), _rsvpColor(g.rsvpStatus)),
                          _tableCellColored(
                            g.isInvitationSent ? '✓ Terkirim' : '- Belum',
                            g.isInvitationSent ? _successGreen : _textMuted,
                          ),
                        ],
                      );
                    }),
                  ],
                ),
                pw.SizedBox(height: 16),
              ],
            );
          }),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'daftar_tamu_${_formatDate(info.weddingDate).replaceAll(' ', '_')}.pdf',
    );
  }

  /// Export rundown ke PDF + share
  Future<void> exportRundownPdf({
    required BuildContext context,
    required WeddingInfo info,
    required List<RundownItem> rundowns,
  }) async {
    final doc = pw.Document();

    // Sort by time
    final sorted = List<RundownItem>.from(rundowns)
      ..sort((a, b) => a.timeRange.compareTo(b.timeRange));

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (ctx) => _buildHeader(info, 'Susunan Acara (Rundown)'),
        footer: (ctx) => _buildFooter(ctx),
        build: (ctx) => [
          if (sorted.isEmpty)
            pw.Center(
              child: pw.Text(
                'Belum ada susunan acara yang dicatat.',
                style: pw.TextStyle(color: _textMuted),
              ),
            )
          else
            ...sorted.map((r) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 10),
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColor.fromInt(0xFFEFE8E8)),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Time badge
                  pw.Container(
                    width: 70,
                    padding: const pw.EdgeInsets.all(6),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromInt(0xFFFAF4E1),
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          r.timeRange,
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: _accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          r.activity,
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: _textDark,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Row(
                          children: [
                            _chip(r.eventType, _primaryColor),
                            if (r.pic.isNotEmpty) ...[
                              pw.SizedBox(width: 6),
                              _chip('PIC: ${r.pic}', PdfColor.fromInt(0xFF4A90E2)),
                            ],
                            if (r.location.isNotEmpty) ...[
                              pw.SizedBox(width: 6),
                              _chip('📍 ${r.location}', _textMuted),
                            ],
                          ],
                        ),
                        if (r.notes.isNotEmpty) ...[
                          pw.SizedBox(height: 4),
                          pw.Text(
                            r.notes,
                            style: pw.TextStyle(fontSize: 10, color: _textMuted),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            )),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'rundown_${_formatDate(info.weddingDate).replaceAll(' ', '_')}.pdf',
    );
  }

  /// Export ringkasan anggaran ke PDF
  Future<void> exportBudgetPdf({
    required BuildContext context,
    required WeddingInfo info,
    required List<ExpenseItem> expenses,
    required double totalBudget,
  }) async {
    final doc = pw.Document();

    final totalEstimated = expenses.fold(0.0, (s, e) => s + e.estimatedCost);
    final totalActual = expenses.fold(0.0, (s, e) => s + (e.actualCost > 0 ? e.actualCost : e.estimatedCost));
    final totalPaid = expenses.fold(0.0, (s, e) => s + e.paidAmount);
    final remaining = totalBudget - totalActual;

    // Group by category
    final grouped = <String, List<ExpenseItem>>{};
    for (final e in expenses) {
      grouped.putIfAbsent(e.category, () => []).add(e);
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (ctx) => _buildHeader(info, 'Ringkasan Anggaran Pernikahan'),
        footer: (ctx) => _buildFooter(ctx),
        build: (ctx) => [
          // Budget summary
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: _bgLight,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: _primaryColor.shade(0.3)),
            ),
            child: pw.Column(
              children: [
                _budgetRow('Total Anggaran', totalBudget, _textDark, bold: true),
                pw.Divider(color: PdfColor.fromInt(0xFFEFE8E8)),
                _budgetRow('Total Estimasi', totalEstimated, _textMuted),
                _budgetRow('Total Aktual', totalActual, _textMuted),
                _budgetRow('Sudah Dibayar', totalPaid, _successGreen),
                pw.Divider(color: PdfColor.fromInt(0xFFEFE8E8)),
                _budgetRow(
                  'Sisa Anggaran',
                  remaining,
                  remaining >= 0 ? _successGreen : _errorRed,
                  bold: true,
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Per category
          ...grouped.entries.map((entry) {
            final catTotal = entry.value.fold(0.0, (s, e) => s + (e.actualCost > 0 ? e.actualCost : e.estimatedCost));
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: pw.BoxDecoration(
                        color: _accentColor,
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Text(
                        entry.key,
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    pw.Text(
                      _formatCurrency(catTotal),
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 11,
                        color: _textDark,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 6),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColor.fromInt(0xFFEFE8E8), width: 0.5),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(2),
                    2: const pw.FlexColumnWidth(2),
                    3: const pw.FlexColumnWidth(2),
                    4: const pw.FlexColumnWidth(1.5),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF9EEF0)),
                      children: [
                        _tableHeader('Item'),
                        _tableHeader('Estimasi'),
                        _tableHeader('Aktual'),
                        _tableHeader('Dibayar'),
                        _tableHeader('Status'),
                      ],
                    ),
                    ...entry.value.asMap().entries.map((e) {
                      final item = e.value;
                      final isPaid = item.isPaid;
                      return pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: e.key.isEven ? PdfColors.white : PdfColor.fromInt(0xFFFBF9F9),
                        ),
                        children: [
                          _tableCell(item.itemName),
                          _tableCell(_formatCurrency(item.estimatedCost)),
                          _tableCell(_formatCurrency(item.actualCost > 0 ? item.actualCost : item.estimatedCost)),
                          _tableCell(_formatCurrency(item.paidAmount)),
                          _tableCellColored(
                            isPaid ? 'Lunas' : 'Belum',
                            isPaid ? _successGreen : _warningOrange,
                          ),
                        ],
                      );
                    }),
                  ],
                ),
                pw.SizedBox(height: 16),
              ],
            );
          }),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'anggaran_${_formatDate(info.weddingDate).replaceAll(' ', '_')}.pdf',
    );
  }

  // ─── Helper builders ─────────────────────────────────────────────────────

  pw.Widget _buildHeader(WeddingInfo info, String title) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: _primaryColor,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '💍 Teman Nikah',
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 10,
              fontWeight: pw.FontWeight.normal,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            title,
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '${info.groomName} & ${info.brideName}  •  ${_formatDate(info.weddingDate)}  •  ${info.venue}',
            style: const pw.TextStyle(color: PdfColors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(pw.Context ctx) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Dibuat dengan Teman Nikah  •  ${DateFormat('d MMM yyyy HH:mm', 'id_ID').format(DateTime.now())}',
          style: const pw.TextStyle(color: _textMuted, fontSize: 9),
        ),
        pw.Text(
          'Halaman ${ctx.pageNumber} dari ${ctx.pagesCount}',
          style: const pw.TextStyle(color: _textMuted, fontSize: 9),
        ),
      ],
    );
  }

  pw.Widget _statBox(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(value, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: _textDark)),
        pw.SizedBox(height: 2),
        pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: _textMuted)),
      ],
    );
  }

  pw.Widget _tableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _textDark),
      ),
    );
  }

  pw.Widget _tableCell(String text, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(text, textAlign: align, style: const pw.TextStyle(fontSize: 9, color: _textDark)),
    );
  }

  pw.Widget _tableCellColored(String text, PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(text, style: pw.TextStyle(fontSize: 9, color: color, fontWeight: pw.FontWeight.bold)),
    );
  }

  pw.Widget _chip(String text, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: pw.BoxDecoration(
        color: color.shade(0.15),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(text, style: pw.TextStyle(fontSize: 8, color: color, fontWeight: pw.FontWeight.bold)),
    );
  }

  pw.Widget _budgetRow(String label, double amount, PdfColor color, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 11, color: _textDark, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(_formatCurrency(amount), style: pw.TextStyle(fontSize: 11, color: color, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ],
      ),
    );
  }

  String _rsvpLabel(RsvpStatus s) {
    switch (s) {
      case RsvpStatus.attending: return 'Hadir';
      case RsvpStatus.declined: return 'Tidak Hadir';
      case RsvpStatus.tentative: return 'Ragu';
      case RsvpStatus.pending: return 'Pending';
    }
  }

  PdfColor _rsvpColor(RsvpStatus s) {
    switch (s) {
      case RsvpStatus.attending: return _successGreen;
      case RsvpStatus.declined: return _errorRed;
      case RsvpStatus.tentative: return _warningOrange;
      case RsvpStatus.pending: return _textMuted;
    }
  }
}
