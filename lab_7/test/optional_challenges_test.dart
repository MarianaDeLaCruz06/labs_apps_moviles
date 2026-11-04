import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moviles_auth/features/auth/domain/entities/app_user.dart';
import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/repository/auth_repository.dart';
import 'package:moviles_auth/features/auth/domain/repository/profile_repository.dart';
import 'package:moviles_auth/features/avatar/domain/entities/photo_source.dart';
import 'package:moviles_auth/features/avatar/domain/entities/picked_photo.dart';
import 'package:moviles_auth/features/avatar/domain/repository/avatar_repository.dart';
import 'package:moviles_auth/features/avatar/domain/usecases/remove_avatar_usecase.dart';
import 'package:moviles_auth/features/posts/domain/entities/post.dart';
import 'package:moviles_auth/features/posts/domain/repository/post_repository.dart';
import 'package:moviles_auth/features/posts/domain/usecases/delete_post_usecase.dart';
import 'package:moviles_auth/features/posts/domain/usecases/get_feed_usecase.dart';
import 'package:moviles_auth/features/posts/data/repository/post_repository_impl.dart';
import 'package:moviles_auth/features/posts/data/source/supabase_post_data_source.dart';
import 'package:moviles_auth/features/posts/data/source/supabase_post_image_data_source.dart';
import 'package:moviles_auth/features/home/ui/bloc/feed_bloc.dart';
import 'package:moviles_auth/features/home/ui/bloc/feed_event.dart';
import 'package:moviles_auth/features/home/ui/bloc/feed_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Post _post(String id, {String? path, bool isMine = false}) => Post(
  id: id,
  content: id,
  createdAt: DateTime(2026),
  authorUsername: 'ana',
  authorName: 'Ana',
  isMine: isMine,
  imagePath: path,
  likeCount: 0,
  likedByMe: false,
);

class _PostRepository implements PostRepository {
  List<Post> feed = [];
  List<String>? signedPaths;
  Post? deleted;
  Object? deleteError;
  Map<String, String> urls = {};

  @override
  Future<List<Post>> fetchFeed({required int page, required int size}) async =>
      feed;

  @override
  Future<Map<String, String>> imageUrls(List<String> paths) async {
    signedPaths = paths;
    return urls;
  }

  @override
  Future<String?> delete(Post post) async {
    deleted = post;
    if (deleteError != null) throw deleteError!;
    return post.imagePath;
  }

  @override
  Future<void> create(String content, {String? imagePath}) async {}
  @override
  Future<List<Post>> fetchMine({int limit = 3}) async => [];
  @override
  Future<String> imageUrl(String path) async => urls[path]!;
  @override
  Future<void> like(String postId) async {}
  @override
  Future<PickedPhoto?> pickImage({
    PhotoSource source = PhotoSource.gallery,
  }) async => null;
  @override
  Future<void> unlike(String postId) async {}
  @override
  Future<String> uploadImage(PickedPhoto photo) async => 'path';
}

class _PostDataSource implements PostDataSource {
  String? deletedId;
  String? deletedImagePath;
  Object? deleteError;

  @override
  Future<String?> deleteOwn(String postId) async {
    deletedId = postId;
    if (deleteError != null) throw deleteError!;
    return deletedImagePath;
  }

  @override
  Future<void> create(String content, {String? imagePath}) async {}
  @override
  Future<List<Post>> fetchFeed({required int page, required int size}) async =>
      [];
  @override
  Future<List<Post>> fetchMine({int limit = 3}) async => [];
  @override
  Future<void> like(String postId) async {}
  @override
  Future<void> unlike(String postId) async {}
}

class _PostImageDataSource implements PostImageDataSource {
  String? removedPath;
  Object? removeError;

  @override
  Future<void> remove(String path) async {
    removedPath = path;
    if (removeError != null) throw removeError!;
  }

  @override
  Future<String> signedUrl(String path) async => 'signed/$path';
  @override
  Future<Map<String, String>> signedUrls(List<String> paths) async => {};
  @override
  Future<String> upload(PickedPhoto photo) async => 'uploaded';
}

class _AuthRepository implements AuthRepository {
  AppUser? user = const AppUser(id: 'u1', email: 'ana@example.com');

  @override
  AppUser? currentUser() => user;
  @override
  Future<AppUser> signIn({required String email, required String password}) =>
      Future.error(StateError('Not used by this test fake'));
  @override
  Future<void> signOut() =>
      Future.error(StateError('Not used by this test fake'));
  @override
  Future<AppUser> signUp({required String email, required String password}) =>
      Future.error(StateError('Not used by this test fake'));
}

class _ProfileRepository implements ProfileRepository {
  String? avatarPath = 'u1/avatar.png';
  String? updatedPath = 'not-called';

  @override
  Future<Profile> getProfile(String id) async =>
      Profile(id: id, username: 'ana', fullName: 'Ana', avatarPath: avatarPath);

  @override
  Future<void> updateAvatarPath(String id, String? path) async {
    updatedPath = path;
    avatarPath = path;
  }

  @override
  Future<void> createProfile(Profile profile) async {}
}

class _AvatarRepository implements AvatarRepository {
  String? removed;

  @override
  Future<void> remove(String path) async => removed = path;
  @override
  Future<PickedPhoto?> pick({PhotoSource source = PhotoSource.gallery}) async =>
      null;
  @override
  Future<String> upload(PickedPhoto photo) async => 'u1/new.png';
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/shared_preferences'),
          (call) async => call.method == 'getAll' ? <String, Object>{} : true,
        );
    await Supabase.initialize(
      url: 'http://localhost',
      publishableKey: 'test-publishable-key',
    );
  });

  test(
    'batch signing preserves order, duplicates and posts without image',
    () async {
      final repository = _PostRepository()
        ..feed = [
          _post('1', path: 'u1/a.png'),
          _post('2'),
          _post('3', path: 'u1/a.png'),
          _post('4', path: 'u1/b.png'),
        ]
        ..urls = {
          'u1/a.png': 'https://signed/a',
          'u1/b.png': 'https://signed/b',
        };

      final result = await GetFeedUseCase(posts: repository)(page: 0, size: 10);

      expect(repository.signedPaths, ['u1/a.png', 'u1/a.png', 'u1/b.png']);
      expect(result.map((post) => post.id), ['1', '2', '3', '4']);
      expect(result[0].imageUrl, 'https://signed/a');
      expect(result[1].imageUrl, isNull);
      expect(result[2].imageUrl, 'https://signed/a');
      expect(result[3].imageUrl, 'https://signed/b');
    },
  );

  test('empty feed does one empty batch operation', () async {
    final repository = _PostRepository();
    final result = await GetFeedUseCase(posts: repository)(page: 0, size: 10);
    expect(result, isEmpty);
    expect(repository.signedPaths, isEmpty);
  });

  test('delete use case rejects a post owned by another account', () async {
    final repository = _PostRepository();
    await expectLater(
      DeletePostUseCase(posts: repository)(_post('foreign')),
      throwsA(isA<Exception>()),
    );
    expect(repository.deleted, isNull);
  });

  test('delete use case delegates an owned post with its image', () async {
    final repository = _PostRepository();
    final post = _post('mine', path: 'u1/photo.png', isMine: true);
    await DeletePostUseCase(posts: repository)(post);
    expect(repository.deleted, same(post));
  });

  test(
    'repository deletes a text-only post without touching Storage',
    () async {
      final data = _PostDataSource();
      final images = _PostImageDataSource();
      final repository = PostRepositoryImpl(dataSource: data, images: images);

      await repository.delete(_post('text-only', isMine: true));

      expect(data.deletedId, 'text-only');
      expect(images.removedPath, isNull);
    },
  );

  test('repository deletes the image returned by the deleted row', () async {
    final data = _PostDataSource()..deletedImagePath = 'u1/photo.png';
    final images = _PostImageDataSource();
    final repository = PostRepositoryImpl(dataSource: data, images: images);

    await repository.delete(
      _post('with-image', path: 'u1/photo.png', isMine: true),
    );

    expect(data.deletedId, 'with-image');
    expect(images.removedPath, 'u1/photo.png');
  });

  test('Storage failure is distinct after PostgreSQL deletion', () async {
    final data = _PostDataSource()..deletedImagePath = 'u1/photo.png';
    final images = _PostImageDataSource()
      ..removeError = Exception('Storage offline');
    final repository = PostRepositoryImpl(dataSource: data, images: images);

    await expectLater(
      repository.delete(
        _post('with-image', path: 'u1/photo.png', isMine: true),
      ),
      throwsA(isA<PostImageCleanupException>()),
    );
    expect(data.deletedId, 'with-image');
    expect(images.removedPath, 'u1/photo.png');
  });

  test('FeedBloc removes a deleted post from feed and profile', () async {
    final repository = _PostRepository();
    final post = _post('mine', isMine: true);
    final bloc = FeedBloc(
      deletePost: DeletePostUseCase(posts: repository),
      initialState: FeedState(
        status: FeedStatus.success,
        posts: [post],
        myPosts: [post],
      ),
    );

    bloc.add(FeedPostDeleteRequested(post));
    final result = await bloc.stream.firstWhere(
      (state) => state.status == FeedStatus.success && state.posts.isEmpty,
    );

    expect(result.posts, isEmpty);
    expect(result.myPosts, isEmpty);
    await bloc.close();
  });

  test('FeedBloc keeps post on PostgreSQL failure', () async {
    final repository = _PostRepository()
      ..deleteError = Exception('Database unavailable');
    final post = _post('mine', isMine: true);
    final bloc = FeedBloc(
      deletePost: DeletePostUseCase(posts: repository),
      initialState: FeedState(
        status: FeedStatus.success,
        posts: [post],
        myPosts: [post],
      ),
    );

    bloc.add(FeedPostDeleteRequested(post));
    final result = await bloc.stream.firstWhere(
      (state) => state.status == FeedStatus.failure,
    );

    expect(result.posts, [post]);
    expect(result.myPosts, [post]);
    expect(result.errorMessage, 'Database unavailable');
    await bloc.close();
  });

  test('FeedBloc removes post but reports Storage cleanup failure', () async {
    final repository = _PostRepository()
      ..deleteError = const PostImageCleanupException('Archivo huÃ©rfano');
    final post = _post('mine', path: 'u1/photo.png', isMine: true);
    final bloc = FeedBloc(
      deletePost: DeletePostUseCase(posts: repository),
      initialState: FeedState(
        status: FeedStatus.success,
        posts: [post],
        myPosts: [post],
      ),
    );

    bloc.add(FeedPostDeleteRequested(post));
    final result = await bloc.stream.firstWhere(
      (state) => state.status == FeedStatus.failure,
    );

    expect(result.posts, isEmpty);
    expect(result.myPosts, isEmpty);
    expect(result.errorMessage, 'Archivo huÃ©rfano');
    await bloc.close();
  });

  test('remove avatar writes NULL before deleting the owned file', () async {
    final profiles = _ProfileRepository();
    final avatars = _AvatarRepository();
    final useCase = RemoveAvatarUseCase(
      auth: _AuthRepository(),
      profiles: profiles,
      avatars: avatars,
    );

    final result = await useCase();

    expect(profiles.updatedPath, isNull);
    expect(avatars.removed, 'u1/avatar.png');
    expect(result.avatarPath, isNull);
  });

  test('remove avatar refuses a path from another user', () async {
    final profiles = _ProfileRepository()..avatarPath = 'u2/avatar.png';
    final avatars = _AvatarRepository();
    final useCase = RemoveAvatarUseCase(
      auth: _AuthRepository(),
      profiles: profiles,
      avatars: avatars,
    );

    await expectLater(useCase(), throwsA(isA<Exception>()));
    expect(profiles.updatedPath, 'not-called');
    expect(avatars.removed, isNull);
  });

  test('picked photo fixture remains below the two MiB limit', () {
    final photo = PickedPhoto(bytes: Uint8List(10), extension: 'png');
    expect(photo.bytes.length, lessThan(2 * 1024 * 1024));
  });
}
