import 'package:notekey_app/features/friends/domain/friend_repository.dart';

class ListFriends {
  final FriendRepository repo;
  ListFriends(this.repo);

  Future<List<String>> call(String userId) => repo.list(userId);
}
