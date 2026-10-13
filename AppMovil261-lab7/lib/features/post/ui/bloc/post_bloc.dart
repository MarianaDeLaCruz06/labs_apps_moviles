import 'package:appmovil261/features/post/domain/models/post.dart';
import 'package:appmovil261/features/post/domain/usecases/create_post_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

// Events
abstract class PostEvent {}

class PostSubmitEvent extends PostEvent {
  final String title;
  final String content;
  PostSubmitEvent({required this.title, required this.content});
}

// States
abstract class PostState {}

class PostInitialState extends PostState {}

class PostLoadingState extends PostState {}

class PostSuccessState extends PostState {
  final Post post;

  PostSuccessState(this.post);
}

class PostErrorState extends PostState {
  final String message;
  PostErrorState(this.message);
}

// BLoC
class PostBloc extends Bloc<PostEvent, PostState> {
  final CreatePostUsecase _usecase = CreatePostUsecase();

  PostBloc() : super(PostInitialState()) {
    on<PostSubmitEvent>(_createPost);
  }

  Future<void> _createPost(
    PostSubmitEvent event,
    Emitter<PostState> emit,
  ) async {
    emit(PostLoadingState());
    try {
      final profileId = Supabase.instance.client.auth.currentUser!.id;
      final post = Post(
        id: const Uuid().v4(),
        title: event.title,
        content: event.content,
        profileId: profileId,
        createdAt: DateTime.now(),
      );
      await _usecase.execute(post);
      emit(PostSuccessState(post));
    } catch (e) {
      emit(PostErrorState(e.toString()));
    }
  }
}
