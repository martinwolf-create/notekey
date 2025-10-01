// Zentrale DB-Schnittstelle: nur Interfaces (keine Implementierungen!)
import 'package:notekey_app/features/ungenutzt/chat/domain/chat_repository.dart';
import 'package:notekey_app/features/ungenutzt/posts/domain/post_repository.dart';
import 'package:notekey_app/features/ungenutzt/events/domain/event_repository.dart';
import 'package:notekey_app/features/ungenutzt/calendar/data/calendar_repository.dart';
import 'package:notekey_app/features/ungenutzt/friends/domain/friend_repository.dart';
import 'package:notekey_app/features/ungenutzt/notifications/domain/notification_repository.dart';

abstract class DatabaseRepository {
  ChatRepository get chat;

  PostRepository get posts;
  EventRepository get events;
  CalendarRepository get calendar;
  FriendRepository get friends;
  NotificationRepository get notifications;
}
