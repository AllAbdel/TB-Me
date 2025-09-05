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
  static FlutterLocalNotificationsPlugin get notifications => _notifications;
  static final LanguageProvider _languageProvider = LanguageProvider();
  
  static String _tr(String key) {
    return _languageProvider.translate(key);
  }
  
  
static Future<void> initialize() async {
  print('🔔 Initialisation des notifications...');

  tz.initializeTimeZones();
  print('🌐 Fuseaux horaires initialisés');

  // ===== NOUVEAU : Création des canaux de notification =====
  const AndroidNotificationChannel channel5Min = AndroidNotificationChannel(
    '5min_reminders',
    'Rappels 5 minutes',
    description: 'Rappels 5 minutes avant la prise',
    importance: Importance.high,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('notification_sound'), // Son personnalisé
  );

  const AndroidNotificationChannel channelTime = AndroidNotificationChannel(
    'time_reminders',
    'Rappels de prise',
    description: 'Rappels à l\'heure exacte de prise',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('notification_sound'), // Son personnalisé
  );

  const AndroidNotificationChannel channelFasting = AndroidNotificationChannel(
    'fasting_reminders',
    'Rappels de jeûne',
    description: 'Rappels 2h avant pour les médicaments à jeun',
    importance: Importance.high,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('notification_sound'), // Son personnalisé
  );

  await _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel5Min);
  await _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channelTime);
  await _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channelFasting);
  // ===== FIN NOUVEAU =====

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
    print('✅ Notifications initialisées: $initialized');
  } catch (e) {
    print('❌ Erreur initialisation notifications: $e');
  }

  await _requestPermissions();
  print('🔔 Permissions demandées');
}
  

static Future<void> _requestPermissions() async {
  if (Platform.isAndroid) {
    // Demander la permission de notification
    await Permission.notification.request();

    // Demander la permission pour les alarmes exactes
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }

    // Demander la permission de stockage
    PermissionStatus storageStatus = await Permission.storage.request();
    if (storageStatus.isDenied) {
      await Permission.manageExternalStorage.request();
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
    _tr('notifications.test_simple'),
    '🔔',
    notificationDetails,
  );
}
  
  static void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
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
    playSound: true,
  );
  
  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );
  
  NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );
  
  await _notifications.zonedSchedule(
    (baseId % 100000) + 4000,
    '✅ Période de jeûne terminée !',
    'Vous pouvez maintenant prendre $medicamentNom $dosage',
    tz.TZDateTime.from(scheduledTime, tz.local),
    notificationDetails,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
  );
}
  
  // Notification 2h avant pour jeûne
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
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
      playSound: true,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    String body = _tr('notifications.fasting_reminder_body');
    
    await _notifications.zonedSchedule(
      (baseId % 100000) + 1000, // S'assurer que l'ID reste petit
      _tr('notifrications.time_reminder_title'),
      body,
      tz.TZDateTime.from(scheduledTime.subtract(const Duration(hours: 2)), tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
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
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      '5min_reminders',
      'Rappels 5 minutes',
      channelDescription: 'Rappels 5 minutes avant la prise',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 300, 100, 300]),
      playSound: true,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
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
      (baseId % 100000) + 3000,
      _tr('notifications.time_reminder_title'),
      body,
      tz.TZDateTime.from(scheduledTime.subtract(const Duration(minutes: 5)), tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
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
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      '5min_reminders', // ID du canal
      'Rappels 5 minutes', // Nom du canal
      channelDescription: 'Rappels 5 minutes avant la prise', // Description
      importance: Importance.max,
      priority: Priority.max,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 300, 100, 300]),
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'), // Ajoute un son personnalisé
      enableLights: true,
      ledColor: Colors.blue,
      ledOnMs: 1000,
      ledOffMs: 500,
    );

    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: 1,
    );
    
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    // Message sans traduction pour éviter les erreurs
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
        (baseId % 100000) + 3000,
        _tr('notifications.time_reminder_title'),
        body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }  static Future<void> cancelNotification(int id) async {
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