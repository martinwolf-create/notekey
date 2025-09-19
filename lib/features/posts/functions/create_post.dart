import 'package:notekey_app/features/posts/domain/post.dart';
import 'package:notekey_app/features/posts/domain/post_repository.dart';

class CreatePost {
  final PostRepository repo;
  CreatePost(this.repo);

  Future<void> call(String id, String authorId, String content) {
    return repo.create(Post(
      id: id,
      authorId: authorId,
      content: content,
      createdAt: DateTime.now(),
    ));
  }
}
