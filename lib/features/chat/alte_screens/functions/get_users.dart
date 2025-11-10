import '../data/in_memory_chat_repository.dart';
import '../data/domain/user_profile.dart';

List<UserProfile> getUsers() => InMemoryChatRepository.instance.allUsers();
