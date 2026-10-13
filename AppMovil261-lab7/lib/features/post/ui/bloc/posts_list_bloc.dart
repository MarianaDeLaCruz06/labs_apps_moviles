import 'dart:async';

import 'package:appmovil261/features/post/domain/exceptions/posts_table_not_found_exception.dart';
import 'package:appmovil261/features/post/domain/models/post.dart';
import 'package:appmovil261/features/post/domain/usecases/watch_posts_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class PostsListEvent {}

class PostsListFetchEvent extends PostsListEvent {}

class PostsListAddOptimisticEvent extends PostsListEvent {
  final Post post;

  PostsListAddOptimisticEvent(this.post);
}

class _PostsUpdatedEvent extends PostsListEvent {
  final List<Post> posts;

  _PostsUpdatedEvent(this.posts);
}

class _PostsSubscriptionErrorEvent extends PostsListEvent {
  final Object error;

  _PostsSubscriptionErrorEvent(this.error);
}

abstract class PostsListState {}

class PostsListInitialState extends PostsListState {}

class PostsListLoadingState extends PostsListState {}

class PostsListLoadedState extends PostsListState {
  final List<Post> posts;

  PostsListLoadedState(this.posts);
}

class PostsListUnavailableState extends PostsListState {}

class PostsListErrorState extends PostsListState {
  final String message;

  PostsListErrorState(this.message);
}

class PostsListBloc extends Bloc<PostsListEvent, PostsListState> {
  final WatchPostsUsecase _watchPostsUsecase = WatchPostsUsecase();

  StreamSubscription<List<Post>>? _postsSubscription;
  final Map<String, Post> _optimisticPosts = {};
  List<Post> _posts = const [];

  PostsListBloc() : super(PostsListInitialState()) {
    on<PostsListFetchEvent>(_subscribeToPosts);
    on<PostsListAddOptimisticEvent>(_addOptimisticPost);
    on<_PostsUpdatedEvent>(_updatePosts);
    on<_PostsSubscriptionErrorEvent>(_handleSubscriptionError);
  }

  Future<void> _subscribeToPosts(
    PostsListFetchEvent event,
    Emitter<PostsListState> emit,
  ) async {
    if (_posts.isEmpty) emit(PostsListLoadingState());

    await _postsSubscription?.cancel();
    _postsSubscription = _watchPostsUsecase.execute().listen(
      (posts) {
        if (!isClosed) add(_PostsUpdatedEvent(posts));
      },
      onError: (Object error) {
        if (!isClosed) add(_PostsSubscriptionErrorEvent(error));
      },
    );
  }

  void _addOptimisticPost(
    PostsListAddOptimisticEvent event,
    Emitter<PostsListState> emit,
  ) {
    if (_posts.any((post) => post.id == event.post.id)) return;

    _optimisticPosts[event.post.id] = event.post;
    _posts = _mergeAndSort(_posts, _optimisticPosts.values);
    emit(PostsListLoadedState(_posts));
  }

  void _updatePosts(_PostsUpdatedEvent event, Emitter<PostsListState> emit) {
    final serverIds = event.posts.map((post) => post.id).toSet();
    _optimisticPosts.removeWhere((id, _) => serverIds.contains(id));
    _posts = _mergeAndSort(event.posts, _optimisticPosts.values);
    emit(PostsListLoadedState(_posts));
  }

  void _handleSubscriptionError(
    _PostsSubscriptionErrorEvent event,
    Emitter<PostsListState> emit,
  ) {
    if (event.error is PostsTableNotFoundException) {
      emit(PostsListUnavailableState());
      return;
    }

    emit(
      PostsListErrorState('No se pudo cargar el Feed. Inténtalo nuevamente.'),
    );
  }

  List<Post> _mergeAndSort(Iterable<Post> first, Iterable<Post> second) {
    final postsById = <String, Post>{};
    for (final post in first) {
      postsById[post.id] = post;
    }
    for (final post in second) {
      postsById[post.id] = post;
    }

    final posts = postsById.values.toList();
    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return posts;
  }

  @override
  Future<void> close() async {
    await _postsSubscription?.cancel();
    await super.close();
  }
}
