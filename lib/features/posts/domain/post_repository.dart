import 'package:notekey_app/features/posts/domain/post.dart';

abstract class PostRepository {
  Future<void> create(Post post);
  Future<List<Post>> list({int limit = 100});
  Future<void> update(Post post);
  Future<void> delete(String postId);
}
