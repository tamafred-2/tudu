abstract class NotificationServiceInterface {
  Future<void> init();
  Future<bool> requestPermission();
  void showNotification(String title, String body);
}
