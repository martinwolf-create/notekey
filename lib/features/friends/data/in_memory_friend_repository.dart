import 'package:notekey_app/features/friends/domain/friend_repository.dart';

class InMemoryFriendRepository implements FriendRepository {
  final Map<String, Set<String>> _friends = {};

  Set<String> _ensure(String userId) =>
      _friends.putIfAbsent(userId, () => <String>{});

  @override
  Future<void> add(String userId, String friendId) async {
    if (userId == friendId) return;
    _ensure(userId).add(friendId);
  }

  @override
  Future<List<String>> list(String userId) async {
    return List.unmodifiable(_friends[userId] ?? const <String>{});
  }

  @override
  Future<void> remove(String userId, String friendId) async {
    _friends[userId]?.remove(friendId);
  }
}
