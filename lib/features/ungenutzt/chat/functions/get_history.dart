import '../data/in_memory_chat_repository.dart';
import '../domain/chat_message.dart';

Future<List<ChatMessage>> getHistory(String chatId, {int limit = 50}) {
  return InMemoryChatRepository.instance.getHistory(chatId, limit: limit);
}
