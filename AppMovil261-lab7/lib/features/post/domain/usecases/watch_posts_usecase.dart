import 'package:appmovil261/features/post/data/repository/post_repository_impl.dart';
import 'package:appmovil261/features/post/domain/models/post.dart';
import 'package:appmovil261/features/post/domain/repository/post_repository.dart';

class WatchPostsUsecase {
  final PostRepository _repository = PostRepositoryImpl();

  Stream<List<Post>> execute() {
    return _repository.watchPosts();
  }
}
