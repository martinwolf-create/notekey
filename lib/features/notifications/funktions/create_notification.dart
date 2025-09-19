import 'package:notekey_app/features/notifications/domain/app_notification.dart';
import 'package:notekey_app/features/notifications/domain/notification_repository.dart';

class CreateNotification {
  final NotificationRepository repo;
  CreateNotification(this.repo);

  Future<void> call({
    required String id,
    required String userId,
    required String title,
    required String body,
    DateTime? createdAt,
  }) =>
      repo.create(AppNotification(
        id: id,
        userId: userId,
        title: title,
        body: body,
        createdAt: createdAt ?? DateTime.now(),
      ));
}
