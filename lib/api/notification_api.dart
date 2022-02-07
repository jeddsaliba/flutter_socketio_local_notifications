// ignore_for_file: prefer_const_constructors
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

class NotificationApi {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();

  static Future _notificationDetails() async {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'channelId',
        'channelName',
        'channelDescription',
        importance: Importance.max
      ),
      iOS: IOSNotificationDetails()
    );
  }
  static Future init({bool initScheduled = false}) async {
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = IOSInitializationSettings();
    final settings = InitializationSettings(android: android, iOS: iOS);

    /* WHEN APP IS CLOSED : START */
    final details = await _notifications.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      onNotifications.add(details.payload);
    }
    /* WHEN APP IS CLOSED : END */

    await _notifications.initialize(settings, onSelectNotification: (payload) async {
      onNotifications.add(payload);
    });
  }
  static Future showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload
  }) async {
    _notifications.show(id, title, body, await _notificationDetails(), payload: payload);
  }
}