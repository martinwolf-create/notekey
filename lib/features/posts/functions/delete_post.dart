import 'package:notekey_app/features/posts/domain/post_repository.dart';

class DeletePost {
  final PostRepository repo;
  DeletePost(this.repo);

  Future<void> call(String postId) => repo.delete(postId);
}
