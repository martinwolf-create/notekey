import 'package:notekey_app/features/notifications/domain/app_notification.dart';

abstract class NotificationRepository {
  Future<void> create(AppNotification notification);
  Future<List<AppNotification>> listForUser(String userId);
  Future<void> delete(String notificationId);
}
