import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moviles_auth/features/auth/domain/usecases/get_my_profile_usecase.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:moviles_auth/features/home/ui/bloc/feed_event.dart';
import 'package:moviles_auth/features/home/ui/bloc/feed_state.dart';
import 'package:moviles_auth/features/posts/domain/entities/post.dart';
import 'package:moviles_auth/features/posts/domain/repository/post_repository.dart';
import 'package:moviles_auth/features/posts/domain/usecases/get_feed_usecase.dart';
import 'package:moviles_auth/features/posts/domain/usecases/get_my_posts_usecase.dart';
import 'package:moviles_auth/features/posts/domain/usecases/toggle_like_usecase.dart';
import 'package:moviles_auth/features/posts/domain/usecases/delete_post_usecase.dart';
import 'package:moviles_auth/features/avatar/domain/usecases/change_avatar_usecase.dart';
import 'package:moviles_auth/features/avatar/domain/usecases/remove_avatar_usecase.dart';

/// Loads the profile and the wall, toggles likes, changes the photo and signs out.
class FeedBloc extends Bloc<FeedEvent, FeedState> {
  static const pageSize = 10;
  final GetMyProfileUseCase _getMyProfile;
  final SignOutUseCase _signOut;
  final GetFeedUseCase _getFeed;
  final GetMyPostsUseCase _getMyPosts;
  final ToggleLikeUseCase _toggleLike;
  final ChangeAvatarUseCase _changeAvatar;
  final RemoveAvatarUseCase _removeAvatar;
  final DeletePostUseCase _deletePost;

  FeedBloc({
    GetMyProfileUseCase? getMyProfile,
    SignOutUseCase? signOut,
    GetFeedUseCase? getFeed,
    GetMyPostsUseCase? getMyPosts,
    ToggleLikeUseCase? toggleLike,
    ChangeAvatarUseCase? changeAvatar,
    RemoveAvatarUseCase? removeAvatar,
    DeletePostUseCase? deletePost,
    FeedState? initialState,
  }) : _getMyProfile = getMyProfile ?? GetMyProfileUseCase(),
       _signOut = signOut ?? SignOutUseCase(),
       _getFeed = getFeed ?? GetFeedUseCase(),
       _getMyPosts = getMyPosts ?? GetMyPostsUseCase(),
       _toggleLike = toggleLike ?? ToggleLikeUseCase(),
       _changeAvatar = changeAvatar ?? ChangeAvatarUseCase(),
       _removeAvatar = removeAvatar ?? RemoveAvatarUseCase(),
       _deletePost = deletePost ?? DeletePostUseCase(),
       super(initialState ?? const FeedState()) {
    on<ProfileRequested>(_onProfileRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<FeedStarted>(_onStarted);
    on<FeedMoreRequested>(_onMoreRequested);
    on<FeedLikeToggled>(_onLikeToggled);
    on<FeedPostDeleteRequested>(_onPostDeleteRequested);
    on<AvatarChangeRequested>(_onAvatarChangeRequested);
    on<AvatarRemoveRequested>(_onAvatarRemoveRequested);
  }

  String _message(Exception e) {
    return e.toString().replaceFirst('Exception: ', '');
  }

  Future<void> _onStarted(FeedStarted event, Emitter<FeedState> emit) async {
    emit(state.copyWith(status: FeedStatus.loading));
    try {
      final posts = await _getFeed(page: 0, size: pageSize);
      final mine = await _getMyPosts();
      emit(
        state.copyWith(
          status: FeedStatus.success,
          posts: posts,
          myPosts: mine,
          page: 0,
          hasMore: posts.length == pageSize,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(status: FeedStatus.failure, errorMessage: _message(e)),
      );
    }
  }

  Future<void> _onMoreRequested(
    FeedMoreRequested event,
    Emitter<FeedState> emit,
  ) async {
    if (!state.hasMore || state.status == FeedStatus.loading) return;
    emit(state.copyWith(status: FeedStatus.loading));
    try {
      final next = await _getFeed(page: state.page + 1, size: pageSize);
      emit(
        state.copyWith(
          status: FeedStatus.success,
          posts: [...state.posts, ...next],
          page: state.page + 1,
          hasMore: next.length == pageSize,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(status: FeedStatus.failure, errorMessage: _message(e)),
      );
    }
  }

  Future<void> _onLikeToggled(
    FeedLikeToggled event,
    Emitter<FeedState> emit,
  ) async {
    try {
      final updated = await _toggleLike(event.post);
      List<Post> swap(List<Post> list) {
        return [
          for (final post in list) post.id == updated.id ? updated : post,
        ];
      }

      emit(
        state.copyWith(posts: swap(state.posts), myPosts: swap(state.myPosts)),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(status: FeedStatus.failure, errorMessage: _message(e)),
      );
    }
  }

  Future<void> _onPostDeleteRequested(
    FeedPostDeleteRequested event,
    Emitter<FeedState> emit,
  ) async {
    if (!event.post.isMine) {
      emit(
        state.copyWith(
          status: FeedStatus.failure,
          errorMessage: 'Solo puedes eliminar tus propias publicaciones',
        ),
      );
      return;
    }

    emit(state.copyWith(status: FeedStatus.loading));
    try {
      await _deletePost(event.post);
      emit(
        state.copyWith(
          status: FeedStatus.success,
          posts: _withoutPost(state.posts, event.post.id),
          myPosts: _withoutPost(state.myPosts, event.post.id),
        ),
      );
    } on PostImageCleanupException catch (e) {
      // PostgreSQL already deleted the post. Keep it removed locally and show
      // the Storage cleanup warning without reloading stale data over the UI.
      emit(
        state.copyWith(
          status: FeedStatus.failure,
          posts: _withoutPost(state.posts, event.post.id),
          myPosts: _withoutPost(state.myPosts, event.post.id),
          errorMessage: e.message,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(status: FeedStatus.failure, errorMessage: _message(e)),
      );
    }
  }

  List<Post> _withoutPost(List<Post> posts, String postId) {
    return posts.where((post) => post.id != postId).toList(growable: false);
  }

  Future<void> _onAvatarChangeRequested(
    AvatarChangeRequested event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.copyWith(avatarStatus: AvatarStatus.uploading));

    try {
      final profile = await _changeAvatar(source: event.source);

      if (profile == null) {
        emit(state.copyWith(avatarStatus: AvatarStatus.idle));
        return;
      }

      emit(state.copyWith(profile: profile, avatarStatus: AvatarStatus.idle));

      add(FeedStarted());
    } on Exception catch (e) {
      debugPrint('ERROR AL SUBIR AVATAR: $e');
      emit(
        state.copyWith(
          avatarStatus: AvatarStatus.failure,
          errorMessage: _message(e),
        ),
      );
    }
  }

  Future<void> _onProfileRequested(
    ProfileRequested event,
    Emitter<FeedState> emit,
  ) async {
    try {
      final profile = await _getMyProfile();
      emit(state.copyWith(profile: profile));
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: FeedStatus.failure,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<FeedState> emit,
  ) async {
    await _signOut();
    emit(state.copyWith(signedOut: true));
  }

  Future<void> _onAvatarRemoveRequested(
    AvatarRemoveRequested event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.copyWith(avatarStatus: AvatarStatus.uploading));

    try {
      final profile = await _removeAvatar();

      emit(state.copyWith(profile: profile, avatarStatus: AvatarStatus.idle));

      // Refresh the feed so avatars update everywhere.
      add(FeedStarted());
    } on Exception catch (e) {
      emit(
        state.copyWith(
          avatarStatus: AvatarStatus.failure,
          errorMessage: _message(e),
        ),
      );
      // The database may already be unlinked if Storage cleanup failed.
      add(ProfileRequested());
      add(FeedStarted());
    }
  }
}
