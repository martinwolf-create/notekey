// Zentrale DB-Schnittstelle: nur Interfaces (keine Implementierungen!)
import 'package:notekey_app/features/chat/domain/chat_repository.dart';
import 'package:notekey_app/features/posts/domain/post_repository.dart';
import 'package:notekey_app/features/events/domain/event_repository.dart';
import 'package:notekey_app/features/calendar/data/calendar_repository.dart';
import 'package:notekey_app/features/friends/domain/friend_repository.dart';
import 'package:notekey_app/features/notifications/domain/notification_repository.dart';

abstract class DatabaseRepository {
  ChatRepository get chat;

  PostRepository get posts;
  EventRepository get events;
  CalendarRepository get calendar;
  FriendRepository get friends;
  NotificationRepository get notifications;
}
