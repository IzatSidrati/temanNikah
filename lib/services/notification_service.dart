import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    // Set timezone Jakarta
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Notification tapped: ${details.payload}');
      },
    );

    _initialized = true;
  }

  /// Minta izin notifikasi (Android 13+)
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  /// Tampilkan notifikasi langsung (tes)
  Future<void> showTestNotification() async {
    await _plugin.show(
      0,
      '🎊 Teman Nikah',
      'Notifikasi pengingat pernikahan aktif!',
      _buildDetails(),
    );
  }

  /// Jadwalkan notifikasi H-X sebelum hari nikah, mengembalikan jumlah pengingat terjadwal
  Future<int> scheduleWeddingReminders(DateTime weddingDate) async {
    // Batalkan semua notifikasi lama terlebih dulu
    await cancelAllReminders();

    final now = DateTime.now();
    int scheduledCount = 0;

    final reminders = [
      {'days': 30, 'id': 1, 'title': '30 Hari Lagi! 🎊', 'body': 'Sebulan lagi hari pernikahan tiba. Cek checklist segera!'},
      {'days': 14, 'id': 2, 'title': '2 Minggu Lagi! 💍', 'body': 'Dua minggu menuju hari bahagia. Pastikan semua vendor sudah konfirmasi!'},
      {'days': 7,  'id': 3, 'title': '1 Minggu Lagi! 🌸', 'body': 'Seminggu lagi! Siapkan semua kebutuhan akhir dan kirim undangan.'},
      {'days': 3,  'id': 4, 'title': '3 Hari Lagi! ✨', 'body': 'Tiga hari menuju hari bahagia. Siapkan mental dan fisikmu!'},
      {'days': 1,  'id': 5, 'title': 'Besok Hari-H! 🔔', 'body': 'Besok adalah hari pernikahanmu. Istirahat yang cukup malam ini!'},
      {'days': 0,  'id': 6, 'title': '🎉 Hari Pernikahanmu!', 'body': 'Selamat Menikah! Semoga menjadi keluarga sakinah, mawaddah, warahmah.'},
    ];

    for (final r in reminders) {
      final days = r['days'] as int;
      final scheduledDate = weddingDate.subtract(Duration(days: days));
      final notifTime = DateTime(
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
        8, // jam 08:00 pagi
        0,
      );

      if (notifTime.isAfter(now)) {
        try {
          await _plugin.zonedSchedule(
            r['id'] as int,
            r['title'] as String,
            r['body'] as String,
            tz.TZDateTime.from(notifTime, tz.local),
            _buildDetails(),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            payload: 'wedding_reminder_${r['id']}',
          );
        } catch (_) {
          // Fallback ke inexact jika izin exact alarm dibatasi di Android 14+
          await _plugin.zonedSchedule(
            r['id'] as int,
            r['title'] as String,
            r['body'] as String,
            tz.TZDateTime.from(notifTime, tz.local),
            _buildDetails(),
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            payload: 'wedding_reminder_${r['id']}',
          );
        }
        scheduledCount++;
      }
    }
    return scheduledCount;
  }

  /// Batalkan semua notifikasi pengingat
  Future<void> cancelAllReminders() async {
    for (int i = 1; i <= 6; i++) {
      await _plugin.cancel(i);
    }
  }

  /// Dapatkan status notifikasi yang terjadwal
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _plugin.pendingNotificationRequests();
  }

  NotificationDetails _buildDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'teman_nikah_channel',
        'Pengingat Pernikahan',
        channelDescription: 'Notifikasi pengingat hari-H dan persiapan pernikahan',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(''),
      ),
    );
  }
}
