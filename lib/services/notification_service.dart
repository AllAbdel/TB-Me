// /lib/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';
import 'dart:io';
import '../providers/language_provider.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static FlutterLocalNotificationsPlugin get notifications => _notifications;
  static final LanguageProvider _languageProvider = LanguageProvider();
  
  static String _tr(String key) {
    return _languageProvider.translate(key);
  }
  
  static Future<void> initialize() async {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Paris'));
  
  const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  
  const InitializationSettings settings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );
  
  try {
    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  } catch (e) {
    print('Erreur initialisation, nettoyage des notifications...');
    // Supprimer toutes les notifications corrompues
    try {
      await _notifications.cancelAll();
    } catch (_) {}
    
    // Réessayer l'initialisation
    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }
  
  await _requestPermissions();
}  
  static Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.notification.request();
      if (await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }
    }
    
    if (Platform.isIOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }
  
  static void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
  }

  static Future<void> showFastingReminder({
    required int baseId,
    required String medicamentNom,
    required String dosage,
    required DateTime scheduledTime,
  }) async {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'fasting_reminders',
      'Rappels de jeûne',
      channelDescription: 'Rappels 2h avant pour les médicaments à jeun',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
    );
    
     DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
     NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    String body = _tr('notifications.fasting_reminder_body')
        .replaceAll('{medication}', medicamentNom)
        .replaceAll('{dosage}', dosage);
    
    await _notifications.zonedSchedule(
      (baseId % 100000) + 1000,
      _tr('notifications.fasting_reminder_title'),
      body,
      tz.TZDateTime.from(scheduledTime.subtract( Duration(hours: 2)), tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> show30MinLateReminder({
    required int baseId,
    required String medicamentNom,
    required String dosage,
    required int nombreComprimes,
    required bool aJeun,
    required DateTime scheduledTime,
  }) async {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      '30min_late_reminders',
      'Rappels retard 30 minutes',
      channelDescription: 'Rappels 30 minutes après si médicament non pris',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500, 200, 500]),
    );
    
     DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
     NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    String plural = nombreComprimes > 1 ? 's' : '';
    String body = '⚠️ Avez-vous pris votre médicament ?\n$medicamentNom $dosage ($nombreComprimes comprimé$plural)';
    
    if (aJeun) {
      body += '\n${_tr('notifications.fasting_note')}';
    }
    
    await _notifications.zonedSchedule(
      (baseId % 100000) + 2000,
      '⏰ Rappel : Médicament non pris',
      body,
      tz.TZDateTime.from(scheduledTime.add( Duration(minutes: 30)), tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> show5MinReminder({
    required int baseId,
    required String medicamentNom,
    required String dosage,
    required int nombreComprimes,
    required bool aJeun,
    required DateTime scheduledTime,
  }) async {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      '5min_reminders',
      'Rappels 5 minutes',
      channelDescription: 'Rappels 5 minutes avant la prise',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 300, 100, 300]),
    );
    
     DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
     NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    String plural = nombreComprimes > 1 ? 's' : '';
    String body = _tr('notifications.5min_reminder_body')
        .replaceAll('{medication}', medicamentNom)
        .replaceAll('{dosage}', dosage)
        .replaceAll('{tablets}', nombreComprimes.toString())
        .replaceAll('{plural}', plural);
    
    if (aJeun) {
      body += _tr('notifications.fasting_note');
    }
    
    await _notifications.zonedSchedule(
      (baseId % 100000) + 3000,
      _tr('notifications.5min_reminder_title'),
      body,
      tz.TZDateTime.from(scheduledTime.subtract( Duration(minutes: 5)), tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> showTimeReminder({
    required int baseId,
    required String medicamentNom,
    required String dosage,
    required int nombreComprimes,
    required bool aJeun,
    required DateTime scheduledTime,
  }) async {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'time_reminders',
      'Rappels de prise',
      channelDescription: 'Rappels à l\'heure exacte de prise',
      importance: Importance.max,
      priority: Priority.max,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1000]),
      enableLights: true,
    );
    
     DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: 1,
    );
    
     NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    String plural = nombreComprimes > 1 ? 's' : '';
    String body = _tr('notifications.time_reminder_body')
        .replaceAll('{medication}', medicamentNom)
        .replaceAll('{dosage}', dosage)
        .replaceAll('{tablets}', nombreComprimes.toString())
        .replaceAll('{plural}', plural);
    
    if (aJeun) {
      body += _tr('notifications.fasting_note');
    }
    
    await _notifications.zonedSchedule(
      (baseId % 100000) + 4000,
      _tr('notifications.time_reminder_title'),
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
  
  static Future<void> cancelMedicationNotifications(int baseId) async {
    await _notifications.cancel((baseId % 100000) + 1000);
    await _notifications.cancel((baseId % 100000) + 2000);
    await _notifications.cancel((baseId % 100000) + 4000);
  }
  
  static Future<void> cancelAllDaysNotifications(int baseId, int dureeTraitement) async {
    for (int day = 0; day < dureeTraitement; day++) {
      final dayId = baseId + (day * 10000);
      await cancelMedicationNotifications(dayId);
    }
  }

  static Future<void> showSimpleTestNotification() async {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test',
      channelDescription: 'Test simple',
      importance: Importance.max,
      priority: Priority.high,
    );
    
     DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
     NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(
      999,
      _tr('notifications.test_simple'),
      'Test notification',
      notificationDetails,
    );
  }

  static Future<void> showCatchupComplete({
    required int baseId,
    required String medicamentNom,
    required String dosage,
    required DateTime scheduledTime,
  }) async {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'catchup_complete',
      'Rattrapage terminé',
      channelDescription: 'Notification quand la période de jeûne est terminée',
      importance: Importance.max,
      priority: Priority.max,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
    );
    
     DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
     NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.zonedSchedule(
      (baseId % 100000) + 5000,
      '✅ Période de jeûne terminée !',
      'Vous pouvez maintenant prendre $medicamentNom $dosage',
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}