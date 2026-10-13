import 'package:appmovil261/features/post/domain/models/post.dart';
import 'package:appmovil261/features/post/domain/exceptions/posts_table_not_found_exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostDataSource {
  final _client = Supabase.instance.client;

  Future<void> createPost(Post post) async {
    await _client.from('posts').insert(post.toJson());
  }

  Future<List<Post>> fetchAllPosts() async {
    try {
      final response = await _client
          .from('posts')
          .select()
          .order('created_at', ascending: false);
      return response.map((e) => Post.fromJson(e)).toList();
    } on PostgrestException catch (error) {
      if (error.code == 'PGRST205') {
        throw const PostsTableNotFoundException();
      }
      rethrow;
    }
  }

  Stream<List<Post>> watchPosts() async* {
    try {
      yield* _client
          .from('posts')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false)
          .map((rows) => rows.map(Post.fromJson).toList());
    } on PostgrestException catch (error) {
      if (error.code == 'PGRST205') {
        throw const PostsTableNotFoundException();
      }
      rethrow;
    }
  }
}
