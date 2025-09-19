import 'package:notekey_app/features/notifications/domain/app_notification.dart';
import 'package:notekey_app/features/notifications/domain/notification_repository.dart';

class InMemoryNotificationRepository implements NotificationRepository {
  final Map<String, List<AppNotification>> _byUser = {};

  List<AppNotification> _ensure(String userId) =>
      _byUser.putIfAbsent(userId, () => <AppNotification>[]);

  @override
  Future<void> create(AppNotification n) async {
    final list = _ensure(n.userId);
    if (list.any((x) => x.id == n.id)) return;
    list.add(n);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<AppNotification>> listForUser(String userId) async {
    return List.unmodifiable(_byUser[userId] ?? const <AppNotification>[]);
  }

  @override
  Future<void> delete(String notificationId) async {
    for (final entry in _byUser.entries) {
      final i = entry.value.indexWhere((x) => x.id == notificationId);
      if (i != -1) {
        entry.value.removeAt(i);
        break;
      }
    }
  }
}
