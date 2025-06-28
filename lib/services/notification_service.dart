import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';
import 'dart:io'; // Pour Platform
import '../providers/language_provider.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static final LanguageProvider _languageProvider = LanguageProvider();
  
  static String _tr(String key) {
    return _languageProvider.translate(key);
  }
  
  static Future<void> initialize() async {
  print('🔔 Initialisation des notifications...'); // Debug
  
  tz.initializeTimeZones();
  print('🌐 Fuseaux horaires initialisés'); // Debug
  
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
    bool? initialized = await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    print('✅ Notifications initialisées: $initialized'); // Debug
  } catch (e) {
    print('❌ Erreur initialisation notifications: $e'); // Debug
  }
  
  await _requestPermissions();
  print('🔔 Permissions demandées'); // Debug
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
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }
  static Future<void> showSimpleTestNotification() async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'test_channel',
    'Test',
    channelDescription: 'Test simple',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
  );
  
  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );
  
  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );
  
  await _notifications.show(
    999,
    'TEST SIMPLE',
    'Si vous voyez ceci, les notifications fonctionnent !',
    notificationDetails,
  );
}
  
  static void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
  }
  
  // Notification 2h avant pour jeûne
  static Future<void> showFastingReminder({
    required int baseId,
    required String medicamentNom,
    required String dosage,
    required DateTime scheduledTime,
  }) async {
      print('⏰ Programmation notification jeûne: $medicamentNom pour ${scheduledTime.subtract(const Duration(hours: 2)).toString()}');

    // ENLEVER const et final
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'fasting_reminders',
      'Rappels de jeûne',
      channelDescription: 'Rappels 2h avant pour les médicaments à jeun',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
      sound: const RawResourceAndroidNotificationSound('medication_sound'),
      icon: '@drawable/medication_icon',
      color: Colors.orange,
      playSound: true,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'medication_sound.wav',
    );
    
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    String body = _tr('notifications.fasting_reminder_body')
        .replaceAll('{medication}', medicamentNom)
        .replaceAll('{dosage}', dosage);
    
    await _notifications.zonedSchedule(
      baseId + 1000,
      _tr('notifications.fasting_reminder_title'),
      body,
      tz.TZDateTime.from(scheduledTime.subtract(const Duration(hours: 2)), tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'fasting|$medicamentNom|$dosage',
    );
      print('✅ Notification jeûne programmée avec ID: ${baseId + 1000}');

  }
  
  // Notification 5 minutes avant
  static Future<void> show5MinReminder({
    required int baseId,
    required String medicamentNom,
    required String dosage,
    required int nombreComprimes,
    required bool aJeun,
    required DateTime scheduledTime,
  }) async {
    print('🔔 Programmation notification 5min: $medicamentNom pour ${scheduledTime.subtract(const Duration(minutes: 5)).toString()}');

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      '5min_reminders',
      'Rappels 5 minutes',
      channelDescription: 'Rappels 5 minutes avant la prise',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 300, 100, 300]),
      sound: const RawResourceAndroidNotificationSound('medication_sound'),
      icon: '@drawable/medication_icon',
      color: Colors.blue,
      playSound: true,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'medication_sound.wav',
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
      baseId + 2000,
      _tr('notifications.5min_reminder_title'),
      body,
      tz.TZDateTime.from(scheduledTime.subtract(const Duration(minutes: 5)), tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: '5min|$medicamentNom|$dosage|$nombreComprimes',
    );
      print('✅ Notification 5min programmée avec ID: ${baseId + 2000}');

  }
  
  // Notification à l'heure exacte
  static Future<void> showTimeReminder({
    
  required int baseId,
  required String medicamentNom,
  required String dosage,
  required int nombreComprimes,
  required bool aJeun,
  required DateTime scheduledTime,
}) async {
  // AJOUTER CE LOG AU DÉBUT :
  print('📱 Programmation notification à l\'heure: $medicamentNom pour ${scheduledTime.toString()}');
  
  AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'time_reminders',
    'Rappels de prise',
    channelDescription: 'Rappels à l\'heure exacte de prise',
    importance: Importance.max,
    priority: Priority.max,
    enableVibration: true,
    vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1000]),
    sound: const RawResourceAndroidNotificationSound('medication_sound'),
    icon: '@drawable/medication_icon',
    color: Colors.green,
    playSound: true,
    enableLights: true,
    ledColor: Colors.green,
    ledOnMs: 1000,
    ledOffMs: 500,
  );
  
  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
    sound: 'medication_sound.wav',
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
    baseId + 3000,
    _tr('notifications.time_reminder_title'),
    body,
    tz.TZDateTime.from(scheduledTime, tz.local),
    notificationDetails,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    payload: 'time|$medicamentNom|$dosage|$nombreComprimes',
  );
  
  // AJOUTER CE LOG À LA FIN :
  print('✅ Notification programmée avec ID: ${baseId + 3000}');
}  
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
  
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
  
  static Future<void> cancelMedicationNotifications(int baseId) async {
    await _notifications.cancel(baseId + 1000);
    await _notifications.cancel(baseId + 2000);
    await _notifications.cancel(baseId + 3000);
  }
}