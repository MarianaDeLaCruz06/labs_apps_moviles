import 'package:moviles_auth/features/avatar/domain/entities/picked_photo.dart';
import 'package:moviles_auth/features/posts/domain/entities/post.dart';
import 'package:moviles_auth/features/avatar/domain/entities/photo_source.dart';

/// PostgreSQL deletion succeeded, but the associated Storage cleanup failed.
class PostImageCleanupException implements Exception {
  final String message;

  const PostImageCleanupException(this.message);

  @override
  String toString() => message;
}

/// Contract of everything the wall can ask about posts, likes and their images.
abstract class PostRepository {
  Future<List<Post>> fetchFeed({required int page, required int size});
  Future<List<Post>> fetchMine({int limit = 3});
  Future<void> create(String content, {String? imagePath});
  Future<void> like(String postId);
  Future<void> unlike(String postId);
  Future<String?> delete(Post post);
  Future<PickedPhoto?> pickImage({PhotoSource source = PhotoSource.gallery});
  Future<String> uploadImage(PickedPhoto photo);
  Future<String> imageUrl(String path);
  Future<Map<String, String>> imageUrls(List<String> paths);
}
