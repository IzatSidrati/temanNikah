import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  /// Ekspor semua data ke file JSON dan share via Android Share Sheet
  Future<bool> exportBackup(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Ambil semua data dari SharedPreferences
      final backupData = {
        'app': 'Teman Nikah',
        'version': '1.0.0',
        'exported_at': DateTime.now().toIso8601String(),
        'data': {
          'nikah_wedding_info': prefs.getString('nikah_wedding_info'),
          'nikah_checklist': prefs.getString('nikah_checklist'),
          'nikah_expenses': prefs.getString('nikah_expenses'),
          'nikah_guests': prefs.getString('nikah_guests'),
          'nikah_vendors': prefs.getString('nikah_vendors'),
          'nikah_rundowns': prefs.getString('nikah_rundowns'),
          'nikah_theme_id': prefs.getString('nikah_theme_id'),
          'nikah_is_onboarded': prefs.getBool('nikah_is_onboarded'),
        },
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);

      // Simpan ke temp file
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${tempDir.path}/teman_nikah_backup_$timestamp.json');
      await file.writeAsString(jsonString);

      // Share file
      final result = await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/json')],
        subject: 'Backup Data Teman Nikah - $timestamp',
        text: 'Data backup Teman Nikah - $timestamp',
      );

      return result.status == ShareResultStatus.success ||
             result.status == ShareResultStatus.dismissed;
    } catch (e) {
      debugPrint('Error export backup: $e');
      return false;
    }
  }

  /// Import data dari string JSON (paste dari file backup)
  Future<ImportResult> importBackup(String jsonString) async {
    try {
      final Map<String, dynamic> backupData = jsonDecode(jsonString);

      // Validasi format backup
      if (backupData['app'] != 'Teman Nikah' || backupData['data'] == null) {
        return const ImportResult(
          success: false,
          message: 'Format file backup tidak valid atau bukan dari Teman Nikah.',
        );
      }

      final data = backupData['data'] as Map<String, dynamic>;
      final prefs = await SharedPreferences.getInstance();

      // Restore semua data
      if (data['nikah_wedding_info'] != null) {
        await prefs.setString('nikah_wedding_info', data['nikah_wedding_info']);
      }
      if (data['nikah_checklist'] != null) {
        await prefs.setString('nikah_checklist', data['nikah_checklist']);
      }
      if (data['nikah_expenses'] != null) {
        await prefs.setString('nikah_expenses', data['nikah_expenses']);
      }
      if (data['nikah_guests'] != null) {
        await prefs.setString('nikah_guests', data['nikah_guests']);
      }
      if (data['nikah_vendors'] != null) {
        await prefs.setString('nikah_vendors', data['nikah_vendors']);
      }
      if (data['nikah_rundowns'] != null) {
        await prefs.setString('nikah_rundowns', data['nikah_rundowns']);
      }
      if (data['nikah_theme_id'] != null) {
        await prefs.setString('nikah_theme_id', data['nikah_theme_id']);
      }
      if (data['nikah_is_onboarded'] != null) {
        await prefs.setBool('nikah_is_onboarded', data['nikah_is_onboarded']);
      }

      final exportedAt = backupData['exported_at'] != null
          ? DateTime.tryParse(backupData['exported_at'])
          : null;
      final dateStr = exportedAt != null
          ? DateFormat('d MMM yyyy HH:mm').format(exportedAt)
          : 'tidak diketahui';

      return ImportResult(
        success: true,
        message: 'Data berhasil dipulihkan dari backup tanggal $dateStr.',
      );
    } on FormatException {
      return const ImportResult(
        success: false,
        message: 'File backup rusak atau tidak bisa dibaca. Pastikan file JSON valid.',
      );
    } catch (e) {
      return ImportResult(
        success: false,
        message: 'Gagal memulihkan data: $e',
      );
    }
  }
}

class ImportResult {
  final bool success;
  final String message;
  const ImportResult({required this.success, required this.message});
}
