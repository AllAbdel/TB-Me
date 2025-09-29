import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../providers/language_provider.dart';

class PermissionService {

  /// Demande toutes les permissions nécessaires
  static Future<void> requestAllPermissions(BuildContext context) async {
    List<String> deniedPermissions = [];
    
    // 1. Permission notifications
    PermissionStatus notificationStatus = await Permission.notification.request();
    if (notificationStatus.isDenied) {
      deniedPermissions.add("Notifications");
    }
    
    // 2. Permission alarmes exactes (Android 12+)
    if (Platform.isAndroid) {
      try {
        PermissionStatus alarmStatus = await Permission.scheduleExactAlarm.request();
        if (alarmStatus.isDenied) {
          deniedPermissions.add("Alarmes exactes");
        }
      } catch (e) {
        print('Permission alarme non disponible: $e');
      }
    }
    
    // Afficher un message si certaines permissions sont refusées
    if (deniedPermissions.isNotEmpty && context.mounted) {
      _showPermissionDialog(context, deniedPermissions);
    }
  }

  static String _tr(String key) {
    final languageProvider = LanguageProvider();
    return languageProvider.translate(key);
  }
  
  static void _showPermissionDialog(BuildContext context, List<String> deniedPermissions) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange[400]!, Colors.red[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                const Icon(Icons.warning, color: Colors.white, size: 30),
                const SizedBox(height: 8),
                Text(
                  _tr('permissions.required_title'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _tr('permissions.required_message'),
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ...deniedPermissions.map((permission) => 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.close, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Text(permission, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(_tr('common.later')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Text(_tr('app.settings')),
            ),
          ],
        );
      },
    );
  }
}