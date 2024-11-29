import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationController {
  // Metode untuk mendeteksi saat notifikasi dibuat
  static Future<void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    debugPrint('Notification Created: ${receivedNotification.id}');
  }

  // Metode untuk mendeteksi saat notifikasi ditampilkan
  static Future<void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    debugPrint('Notification Displayed: ${receivedNotification.id}');
  }

  // Metode untuk mendeteksi saat notifikasi ditutup/dibatalkan
  static Future<void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    debugPrint('Notification Dismissed: ${receivedAction.id}');
  }

  // Metode untuk menangani aksi saat notifikasi diklik
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    debugPrint('Notification Action Received: ${receivedAction.id}');
  }

  // Inisialisasi notifikasi dan channel
  static Future<void> initializeNotification() async {
    await AwesomeNotifications().initialize(
      'resource://drawable/ic_notification',
      [
        NotificationChannel(
          channelKey: 'alerts',
          channelName: 'Basic Notifications',
          channelDescription: 'Notification channel for basic alerts',
          defaultColor: Colors.blue,
          ledColor: Colors.blue,
          importance: NotificationImportance.High,
        ),
        NotificationChannel(
          channelKey: 'promo_channel',
          channelName: 'Promo Notifications',
          channelDescription: 'Notification channel for product promotions',
          defaultColor: Colors.orange,
          ledColor: Colors.orange,
          importance: NotificationImportance.High,
        ),
      ],
    );
  }

  // Membuat notifikasi dengan delay default 5 detik
  static Future<void> createNotificationWithDelay({
    int id = 12,
    String title = 'Notifikasi',
    String body = 'Barang Sudah Dipesan',
    Duration delay = const Duration(seconds: 5),
    Map<String, String>? payload,
  }) async {
    await Future.delayed(delay);

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'alerts',
        title: title,
        body: body,
        payload: payload,
        icon: 'resource://drawable/ic_notification',
      ),
    );
  }

  // Membuat notifikasi instan
  static Future<void> createNotification({
    int id = 12,
    String title = 'Notifikasi',
    String body = 'Barang Sudah Dipesan',
    Map<String, String>? payload,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'alerts',
        title: title,
        body: body,
        payload: payload,
        icon: 'resource://drawable/ic_notification',
      ),
    );
  }

  // Menjadwalkan notifikasi promo
  static Future<void> schedulePromoNotifications() async {
    // Batalkan notifikasi yang sudah ada sebelumnya
    await cancelAllScheduledNotifications();

    // Promo Pagi (jam 6 pagi)
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 601,
        channelKey: 'promo_channel',
        title: 'Promo Pagi Spesial',
        body: 'Jangan Ketinggalan Obral Pagi ini',
      ),
      schedule: NotificationCalendar(
        hour: 6,
        minute: 0,
        second: 0,
        repeats: true,
      ),
    );

    // Promo Siang (jam 12 siang)
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 602,
        channelKey: 'promo_channel',
        title: 'Promo Siang Hemat',
        body: 'Jangan Ketinggalan Obral Siang ini',
      ),
      schedule: NotificationCalendar(
        hour: 12,
        minute: 0,
        second: 0,
        repeats: true,
      ),
    );

    // Promo Sore (jam 4 sore)
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 603,
        channelKey: 'promo_channel',
        title: 'Promo Sore Menguntungkan',
        body: 'Obral spesial sore ini! Jangan sampai kehabisan!',
      ),
      schedule: NotificationCalendar(
        hour: 16,
        minute: 0,
        second: 0,
        repeats: true,
      ),
    );

    // Promo Malam (jam 9 malam)
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 604,
        channelKey: 'promo_channel',
        title: 'Promo Malam Spesial',
        body: 'Obral malam ini! Datang dan Dapatkan Barang Impianmu',
      ),
      schedule: NotificationCalendar(
        hour: 21,
        minute: 0,
        second: 0,
        repeats: true,
      ),
    );
  }

  // Membatalkan semua notifikasi terjadwal
  static Future<void> cancelAllScheduledNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

  // Menjadwalkan ulang notifikasi promo
  static Future<void> reschedulePromoNotifications() async {
    await cancelAllScheduledNotifications();
    await schedulePromoNotifications();
  }

  // Metode untuk memeriksa dan meminta izin notifikasi
  static Future<bool> requestNotificationPermissions() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      // Meminta izin notifikasi
      isAllowed = await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    return isAllowed;
  }
}