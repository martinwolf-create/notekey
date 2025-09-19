import 'package:notekey_app/features/friends/domain/friend_repository.dart';

class RemoveFriend {
  final FriendRepository repo;
  RemoveFriend(this.repo);

  Future<void> call(String userId, String friendId) =>
      repo.remove(userId, friendId);
}
