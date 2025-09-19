import '../data/in_memory_chat_repository.dart';
import '../domain/chat_thread.dart';

Future<List<ChatThread>> fetchRecentChats({int limit = 10}) async {
  final repo = InMemoryChatRepository.instance;
  final ids = await repo.fetchRecentChatIds(limit: limit);
  final out = <ChatThread>[];
  for (final id in ids) {
    out.add(await repo.getThread(id));
  }
  return out;
}
