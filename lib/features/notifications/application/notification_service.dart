import 'notification_service_interface.dart';
import 'notification_service_stub.dart'
    if (dart.library.html) 'notification_service_web.dart';

class NotificationService {
  static final NotificationServiceInterface _instance = getNotificationService();

  static NotificationServiceInterface get instance => _instance;
}
