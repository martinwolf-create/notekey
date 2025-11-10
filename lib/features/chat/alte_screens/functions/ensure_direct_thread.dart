import '../data/in_memory_chat_repository.dart';

Future<String> ensureDirectThread(String otherUserId) {
  return InMemoryChatRepository.instance.ensureDirectThread(otherUserId);
}
