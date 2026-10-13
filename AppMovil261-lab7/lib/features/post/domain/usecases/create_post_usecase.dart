import 'package:appmovil261/features/post/data/repository/post_repository_impl.dart';
import 'package:appmovil261/features/post/domain/models/post.dart';
import 'package:appmovil261/features/post/domain/repository/post_repository.dart';

class CreatePostUsecase {
  final PostRepository _repository = PostRepositoryImpl();

  Future<void> execute(Post post) async {
    await _repository.createPost(post);
  }
}
