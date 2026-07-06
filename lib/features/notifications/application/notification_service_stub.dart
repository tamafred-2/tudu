import 'notification_service_interface.dart';

class StubNotificationService implements NotificationServiceInterface {
  @override
  Future<void> init() async {
    // Stub
  }

  @override
  Future<bool> requestPermission() async {
    return false;
  }

  @override
  void showNotification(String title, String body) {
    // Stub
  }
}

NotificationServiceInterface getNotificationService() => StubNotificationService();
