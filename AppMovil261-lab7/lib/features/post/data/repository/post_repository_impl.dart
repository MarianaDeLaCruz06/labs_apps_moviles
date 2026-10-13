import 'package:appmovil261/features/post/data/sources/post_data_source.dart';
import 'package:appmovil261/features/post/domain/models/post.dart';
import 'package:appmovil261/features/post/domain/repository/post_repository.dart';

class PostRepositoryImpl implements PostRepository {
  final PostDataSource _dataSource = PostDataSource();

  @override
  Future<void> createPost(Post post) async {
    await _dataSource.createPost(post);
  }

  @override
  Future<List<Post>> fetchAllPosts() async {
    return _dataSource.fetchAllPosts();
  }

  @override
  Stream<List<Post>> watchPosts() {
    return _dataSource.watchPosts();
  }
}
