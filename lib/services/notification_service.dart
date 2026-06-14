import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // API 28 memerlukan ikon yang valid. 
    // Jika 'weather_icon' belum ada di res/drawable, ganti ke '@mipmap/ic_launcher'
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Logika saat notifikasi diklik
      },
    );

    // Izin notifikasi khusus Android 13+ (tidak berpengaruh di API 28 tapi bagus untuk jaga-jaga)
    if (Platform.isAndroid) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  static Future<void> showWeatherNotification({
    required String city,
    required String temp,
    required String condition,
  }) async {
    // API 28 (Android 9) WAJIB menggunakan Channel ID
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'weather_channel_id', // ID unik
      'Weather Updates',     // Nama channel yang muncul di setting HP
      channelDescription: 'Menampilkan status cuaca di panel notifikasi',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true,         // Notifikasi tidak bisa dihapus swipe (tetap di Control Center)
      styleInformation: BigTextStyleInformation(''),
      icon: '@mipmap/ic_launcher', // Sementara gunakan ic_launcher agar tidak crash
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      0,
      city,
      '$temp - $condition',
      platformChannelSpecifics,
    );
  }

  static Future<void> cancelNotification() async {
    await _notificationsPlugin.cancel(0);
  }
}
