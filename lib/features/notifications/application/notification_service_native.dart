import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_service_interface.dart';

class NativeNotificationService implements NotificationServiceInterface {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  Future<void>? _initFuture;
  int _notificationId = 0;

  @override
  Future<void> init() {
    return _initFuture ??= _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
        macOS: DarwinInitializationSettings(),
        linux: LinuxInitializationSettings(defaultActionName: 'Open'),
        windows: WindowsInitializationSettings(
          appName: 'Tudu',
          appUserModelId: 'TamaFred.Tudu',
          guid: 'a3f5c8d2-7e91-4b6a-b0c4-95d21f83e7a6',
        ),
      ),
    );
  }

  @override
  Future<bool> requestPermission() async {
    await init();
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await android?.requestNotificationsPermission() ?? false;
    }
    if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      return await ios?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
    // Windows, macOS and Linux do not require a runtime permission request here.
    return true;
  }

  @override
  void showNotification(String title, String body) {
    _show(title, body);
  }

  Future<void> _show(String title, String body) async {
    await init();
    await _plugin.show(
      id: _notificationId++,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'tudu_reminders',
          'Daily Reminders',
          channelDescription: 'Daily task reminder notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
        windows: WindowsNotificationDetails(),
      ),
    );
  }
}

NotificationServiceInterface getNotificationService() =>
    NativeNotificationService();
