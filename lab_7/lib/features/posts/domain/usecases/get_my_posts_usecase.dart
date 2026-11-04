import 'package:moviles_auth/features/posts/data/repository/post_repository_impl.dart';
import 'package:moviles_auth/features/posts/domain/entities/post.dart';
import 'package:moviles_auth/features/posts/domain/repository/post_repository.dart';

/// Brings the latest posts of the signed in user.
class GetMyPostsUseCase {
  final PostRepository _posts;

  GetMyPostsUseCase({PostRepository? posts})
    : _posts = posts ?? PostRepositoryImpl();

  Future<List<Post>> call({int limit = 3}) async {
    final posts = await _posts.fetchMine(limit: limit);

    final paths = posts
        .map((post) => post.imagePath)
        .whereType<String>()
        .toList(growable: false);
    final urls = await _posts.imageUrls(paths);
    return [
      for (final post in posts)
        if (post.imagePath case final path?)
          post.copyWith(imageUrl: urls[path])
        else
          post,
    ];
  }
}
