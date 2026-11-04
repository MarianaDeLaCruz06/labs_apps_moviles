import 'package:moviles_auth/features/posts/data/repository/post_repository_impl.dart';
import 'package:moviles_auth/features/posts/domain/entities/post.dart';
import 'package:moviles_auth/features/posts/domain/repository/post_repository.dart';

/// Deletes an owned post first and its associated Storage object afterwards.
class DeletePostUseCase {
  final PostRepository _posts;

  DeletePostUseCase({PostRepository? posts})
    : _posts = posts ?? PostRepositoryImpl();

  Future<void> call(Post post) async {
    if (!post.isMine) {
      throw Exception('Solo puedes eliminar tus propias publicaciones');
    }
    await _posts.delete(post);
  }
}
