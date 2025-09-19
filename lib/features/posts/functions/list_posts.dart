import 'package:notekey_app/features/posts/domain/post.dart';
import 'package:notekey_app/features/posts/domain/post_repository.dart';

class ListPosts {
  final PostRepository repo;
  ListPosts(this.repo);

  Future<List<Post>> call({int limit = 100}) => repo.list(limit: limit);
}
