import '../data/in_memory_chat_repository.dart';
import '../domain/chat_message.dart';

Future<void> sendMessage(String chatId, String text) {
  final repo = InMemoryChatRepository.instance;
  final me = repo.currentUser();
  final msg = ChatMessage(
    id: 'm-${DateTime.now().microsecondsSinceEpoch}',
    chatId: chatId,
    senderId: me.id,
    text: text,
    sentAt: DateTime.now(),
  );
  return repo.sendMessage(msg);
}
