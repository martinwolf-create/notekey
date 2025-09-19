import 'package:notekey_app/features/friends/domain/friend_repository.dart';

class AddFriend {
  final FriendRepository repo;
  AddFriend(this.repo);

  Future<void> call(String userId, String friendId) =>
      repo.add(userId, friendId);
}
