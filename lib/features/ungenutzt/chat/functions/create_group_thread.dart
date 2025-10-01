import '../data/in_memory_chat_repository.dart';

Future<String> createGroupThread(String name, List<String> memberIds) {
  return InMemoryChatRepository.instance.createGroupThread(name, memberIds);
}
