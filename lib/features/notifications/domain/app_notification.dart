// Name "AppNotification" um Konflikt mit Flutter Notification zu vermeiden.
class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdAt,
  });
}
