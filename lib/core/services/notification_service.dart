import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const init = InitializationSettings(android: android);
    await _plugin.initialize(init);

    const channel = AndroidNotificationChannel(
      'cyberai_general',
      'CyberAI Notifications',
      description: 'General alerts and tips from CyberAI',
      importance: Importance.defaultImportance,
    );
    await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  }

  static Future<void> show({required String title, required String body}) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'cyberai_general',
        'CyberAI Notifications',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
    );
    await _plugin.show(DateTime.now().millisecondsSinceEpoch ~/ 1000, title, body, details);
  }
}
