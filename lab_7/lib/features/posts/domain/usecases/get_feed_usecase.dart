import 'package:moviles_auth/features/posts/data/repository/post_repository_impl.dart';
import 'package:moviles_auth/features/posts/domain/entities/post.dart';
import 'package:moviles_auth/features/posts/domain/repository/post_repository.dart';

/// Brings one page of the wall, newest first.
class GetFeedUseCase {
  final PostRepository _posts;

  GetFeedUseCase({PostRepository? posts})
    : _posts = posts ?? PostRepositoryImpl();

  Future<List<Post>> call({required int page, required int size}) async {
    final posts = await _posts.fetchFeed(page: page, size: size);

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
