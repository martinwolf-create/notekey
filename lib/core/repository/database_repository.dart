// Zentrale DB-Schnittstelle: nur Interfaces (keine Implementierungen!)
import 'package:notekey_app/core/detail_repo/chat/domain/chat_repository.dart';
import 'package:notekey_app/core/detail_repo/posts/domain/post_repository.dart';
import 'package:notekey_app/core/detail_repo/events/domain/event_repository.dart';
import 'package:notekey_app/core/detail_repo/calendar/data/calendar_repository.dart';
import 'package:notekey_app/core/detail_repo/friends/domain/friend_repository.dart';
import 'package:notekey_app/core/detail_repo/notifications/domain/notification_repository.dart';

abstract class DatabaseRepository {
  ChatRepository get chat;

  PostRepository get posts;
  EventRepository get events;
  CalendarRepository get calendar;
  FriendRepository get friends;
  NotificationRepository get notifications;
}
