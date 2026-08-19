import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Displays notifications that arrive while the app is in the foreground.
/// FCM foreground messages don't auto-show a system notification, so
/// [FcmService] routes them here. No on-device scheduling — reminders
/// would need a server-side sender (a Cloud Function) to be reliable, which
/// this project doesn't currently have.
class LocalNotificationService {
  LocalNotificationService() : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  static const _channelId = 'task_manager_general';
  static const _channelName = 'Task Manager';
  static const _androidDetails = AndroidNotificationDetails(
    _channelId,
    _channelName,
    importance: Importance.high,
    priority: Priority.high,
  );

  Future<void> initialize() async {
    if (_initialized) return;
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(_channelId, _channelName, importance: Importance.high),
    );

    final iosImpl = _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await iosImpl?.requestPermissions(alert: true, badge: true, sound: true);

    _initialized = true;
  }

  Future<void> showNow({required String title, required String body}) {
    return _plugin.show(
      DateTime.now().millisecondsSinceEpoch & 0x7fffffff,
      title,
      body,
      const NotificationDetails(android: _androidDetails, iOS: DarwinNotificationDetails()),
    );
  }
}
