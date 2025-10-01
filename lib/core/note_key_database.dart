import 'package:notekey_app/core/repository/database_repository.dart';

// Interfaces(funktion)
import 'package:notekey_app/features/ungenutzt/chat/domain/chat_repository.dart';
import 'package:notekey_app/features/ungenutzt/posts/domain/post_repository.dart';
import 'package:notekey_app/features/ungenutzt/events/domain/event_repository.dart';
import 'package:notekey_app/features/ungenutzt/calendar/data/calendar_repository.dart';
import 'package:notekey_app/features/ungenutzt/friends/domain/friend_repository.dart';
import 'package:notekey_app/features/ungenutzt/notifications/domain/notification_repository.dart';

// In-Memory...
import 'package:notekey_app/features/ungenutzt/chat/data/in_memory_chat_repository.dart';
import 'package:notekey_app/features/ungenutzt/posts/data/in_memory_post_repository.dart';
import 'package:notekey_app/features/ungenutzt/events/data/in_memory_event_repository.dart';
import 'package:notekey_app/features/ungenutzt/calendar/data/in_memory_calendar_repository.dart';
import 'package:notekey_app/features/ungenutzt/friends/data/in_memory_friend_repository.dart';
import 'package:notekey_app/features/ungenutzt/notifications/data/in_memory_notification_repository.dart';

class InMemoryNoteKeyDatabase implements DatabaseRepository {
  InMemoryNoteKeyDatabase._();
  static final InMemoryNoteKeyDatabase instance = InMemoryNoteKeyDatabase._();

  // repos
  final InMemoryChatRepository _chat = InMemoryChatRepository.instance;
  final InMemoryPostRepository _posts = InMemoryPostRepository();
  final InMemoryEventRepository _events = InMemoryEventRepository();
  final InMemoryCalendarRepository _calendar = InMemoryCalendarRepository();
  final InMemoryFriendRepository _friends = InMemoryFriendRepository();
  final InMemoryNotificationRepository _notifications =
      InMemoryNotificationRepository();

  // from DatabaseRepository
  @override
  ChatRepository get chat => _chat;
  @override
  PostRepository get posts => _posts;
  @override
  EventRepository get events => _events;
  @override
  CalendarRepository get calendar => _calendar;
  @override
  FriendRepository get friends => _friends;
  @override
  NotificationRepository get notifications => _notifications;
}

// Qlobaler Zugriff
final noteKeyDb = InMemoryNoteKeyDatabase.instance;
