import 'package:notekey_app/features/posts/domain/post.dart';
import 'package:notekey_app/features/posts/domain/post_repository.dart';

class InMemoryPostRepository implements PostRepository {
  final List<Post> _posts = [];

  @override
  Future<void> create(Post post) async {
    if (_posts.any((p) => p.id == post.id)) return;
    _posts.add(post);
    _posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<Post>> list({int limit = 100}) async {
    final copy = List<Post>.unmodifiable(_posts);
    return copy.take(limit).toList();
  }

  @override
  Future<void> update(Post post) async {
    final i = _posts.indexWhere((p) => p.id == post.id);
    if (i != -1) _posts[i] = post;
  }

  @override
  Future<void> delete(String postId) async {
    _posts.removeWhere((p) => p.id == postId);
  }
}
