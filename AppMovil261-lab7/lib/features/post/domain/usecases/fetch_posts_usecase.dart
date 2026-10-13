import 'package:appmovil261/features/post/data/repository/post_repository_impl.dart';
import 'package:appmovil261/features/post/domain/models/post.dart';
import 'package:appmovil261/features/post/domain/repository/post_repository.dart';

class FetchPostsUsecase {
  final PostRepository _repository = PostRepositoryImpl();

  Future<List<Post>> execute() async {
    return _repository.fetchAllPosts();
  }
}
