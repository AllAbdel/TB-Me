import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:my_tuberculose/services/translation_service.dart';
import '../providers/language_provider.dart';
import 'package:my_tuberculose/services/notification_service.dart';

class PermissionService {

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
    
    // 3. Permission stockage - SIMPLIFIÉE pour Android 13+
    if (Platform.isAndroid) {
      // Essayer d'abord la permission basique
      PermissionStatus storageStatus = await Permission.storage.request();
      
      if (storageStatus.isDenied) {
        // Si refusée, essayer les fichiers multimédias pour Android 13+
        try {
          PermissionStatus mediaStatus = await Permission.photos.request();
          if (mediaStatus.isDenied) {
            deniedPermissions.add("Stockage");
          }
        } catch (e) {
          print('Permission photos non disponible: $e');
          deniedPermissions.add("Stockage");
        }
      }
    }
    
    // Afficher un message si certaines permissions sont refusées
    if (deniedPermissions.isNotEmpty && context.mounted) {
      _showPermissionDialog(context, deniedPermissions);
    }
  }

  // CORRECTION : Créer une instance de LanguageProvider pour les méthodes statiques
  static String _tr(String key) {
    final languageProvider = LanguageProvider();
    return languageProvider.translate(key);
  }
  
  static Future<bool> _isAndroid13OrHigher() async {
    if (!Platform.isAndroid) return false;
    // Simple vérification - vous pouvez utiliser device_info_plus pour plus de précision
    return true; // Assume Android 13+ pour simplifier
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
            child: const Column(
              children: [
                Icon(Icons.warning, color: Colors.white, size: 30),
                SizedBox(height: 8),
                Text(
                  'Permissions requises',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'L\'application a besoin des permissions suivantes pour fonctionner correctement :',
                style: TextStyle(fontSize: 16),
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
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Text(
                  _tr('notifications.permissions_help'),
                  style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Plus tard'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings(); // Ouvre les paramètres de l'app
              },
              child: Text(_tr('app.settings')),
            ),
          ],
        );
      },
    );
  }
}