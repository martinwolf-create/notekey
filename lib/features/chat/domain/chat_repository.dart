import 'chat_message.dart';
import 'chat_thread.dart';
import 'user_profile.dart';

abstract class ChatRepository {
  // Nachrichten
  Future<void> sendMessage(ChatMessage message);
  Stream<List<ChatMessage>> watchMessages(String chatId);
  Future<List<ChatMessage>> getHistory(String chatId, {int limit = 50});

  // Threads
  Future<List<String>> fetchRecentChatIds({int limit = 10});
  Future<ChatThread> getThread(String chatId);

  // Komfort
  Future<String> ensureDirectThread(String otherUserId);
  Future<String> createGroupThread(String name, List<String> memberIds);

  // Nutzer
  UserProfile currentUser();
  List<UserProfile> allUsers();
}
