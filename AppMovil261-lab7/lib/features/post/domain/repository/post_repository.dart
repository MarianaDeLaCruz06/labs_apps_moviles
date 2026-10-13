import 'package:appmovil261/features/post/domain/models/post.dart';

abstract class PostRepository {
  Future<void> createPost(Post post);
  Future<List<Post>> fetchAllPosts();
  Stream<List<Post>> watchPosts();
}
