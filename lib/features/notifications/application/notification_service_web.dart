// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'notification_service_interface.dart';

class WebNotificationService implements NotificationServiceInterface {
  @override
  Future<void> init() async {
    if (!html.Notification.supported) {
      html.window.console.warn('Web Notifications are not supported in this browser.');
    }
  }

  @override
  Future<bool> requestPermission() async {
    if (!html.Notification.supported) return false;
    final permission = await html.Notification.requestPermission();
    return permission == 'granted';
  }

  @override
  void showNotification(String title, String body) {
    if (!html.Notification.supported) return;
    if (html.Notification.permission == 'granted') {
      html.Notification(title, body: body);
    } else {
      // Try requesting permission and showing
      html.Notification.requestPermission().then((permission) {
        if (permission == 'granted') {
          html.Notification(title, body: body);
        }
      });
    }
  }
}

NotificationServiceInterface getNotificationService() => WebNotificationService();
