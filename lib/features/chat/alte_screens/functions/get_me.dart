import '../data/in_memory_chat_repository.dart';
import '../data/domain/user_profile.dart';

UserProfile getMe() => InMemoryChatRepository.instance.currentUser();
