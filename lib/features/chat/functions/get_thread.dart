import '../data/in_memory_chat_repository.dart';
import '../domain/chat_thread.dart';

Future<ChatThread> getThread(String chatId) {
  return InMemoryChatRepository.instance.getThread(chatId);
}
