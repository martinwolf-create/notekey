import '../data/in_memory_chat_repository.dart';
import '../domain/chat_message.dart';

Stream<List<ChatMessage>> watchMessages(String chatId) {
  return InMemoryChatRepository.instance.watchMessages(chatId);
}
