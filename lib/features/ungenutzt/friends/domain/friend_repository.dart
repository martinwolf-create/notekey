abstract class FriendRepository {
  Future<void> add(String userId, String friendId);
  Future<List<String>> list(String userId);
  Future<void> remove(String userId, String friendId);
}
