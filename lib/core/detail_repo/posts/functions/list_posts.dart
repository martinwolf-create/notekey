import 'package:notekey_app/core/detail_repo/posts/domain/post.dart';
import 'package:notekey_app/core/detail_repo/posts/domain/post_repository.dart';

class ListPosts {
  final PostRepository repo;
  ListPosts(this.repo);

  Future<List<Post>> call({int limit = 100}) => repo.list(limit: limit);
}
