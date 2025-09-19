import 'package:notekey_app/features/notifications/domain/app_notification.dart';
import 'package:notekey_app/features/notifications/domain/notification_repository.dart';

class ListNotificationsForUser {
  final NotificationRepository repo;
  ListNotificationsForUser(this.repo);

  Future<List<AppNotification>> call(String userId) => repo.listForUser(userId);
}
