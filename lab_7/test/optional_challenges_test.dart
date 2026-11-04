import 'dart:typed_data';

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
