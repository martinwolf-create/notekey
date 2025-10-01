import 'package:notekey_app/features/ungenutzt/notifications/domain/notification_repository.dart';

class DeleteNotification {
  final NotificationRepository repo;
  DeleteNotification(this.repo);

  Future<void> call(String id) => repo.delete(id);
}
