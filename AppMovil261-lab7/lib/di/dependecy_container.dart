import 'package:get_it/get_it.dart';

// Auth
import 'package:appmovil261/features/auth/data/sources/auth_data_source.dart';
import 'package:appmovil261/features/auth/data/repo/auth_repo_impl.dart';
import 'package:appmovil261/features/auth/domain/repo/auth_repo.dart';
import 'package:appmovil261/features/auth/domain/usecases/login_usecase.dart';
import 'package:appmovil261/features/auth/domain/usecases/logout_usecase.dart';
import 'package:appmovil261/features/auth/domain/usecases/signup_usecase.dart';
import 'package:appmovil261/features/login/ui/bloc/login_bloc.dart';
import 'package:appmovil261/features/signup/ui/bloc/signup_bloc.dart';

// Chat
import 'package:appmovil261/features/chat/data/sources/chat_data_source.dart';
import 'package:appmovil261/features/chat/data/repository/chat_repository_impl.dart';
import 'package:appmovil261/features/chat/domain/repository/chat_repository.dart';
import 'package:appmovil261/features/chat/domain/usecases/get_or_create_conversation_usecase.dart';
import 'package:appmovil261/features/chat/domain/usecases/get_profiles_usecase.dart';
import 'package:appmovil261/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:appmovil261/features/chat/domain/usecases/watch_messages_usecase.dart';
import 'package:appmovil261/features/chat/ui/bloc/chat_bloc.dart';
import 'package:appmovil261/features/chat/ui/bloc/users_bloc.dart';

// Post
import 'package:appmovil261/features/post/data/sources/post_data_source.dart';
import 'package:appmovil261/features/post/data/repository/post_repository_impl.dart';
import 'package:appmovil261/features/post/domain/repository/post_repository.dart';
import 'package:appmovil261/features/post/domain/usecases/create_post_usecase.dart';
import 'package:appmovil261/features/post/domain/usecases/fetch_posts_usecase.dart';
import 'package:appmovil261/features/post/domain/usecases/watch_posts_usecase.dart';
import 'package:appmovil261/features/post/ui/bloc/post_bloc.dart';
import 'package:appmovil261/features/post/ui/bloc/posts_list_bloc.dart';

// Profile
import 'package:appmovil261/features/profile/data/source/profile_data_source.dart';
import 'package:appmovil261/features/profile/data/repository/profile_repository_impl.dart';
import 'package:appmovil261/features/profile/domain/repository/profile_repository.dart';
import 'package:appmovil261/features/profile/ui/bloc/profile_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ── Auth ────────────────────────────────────────────
  sl.registerLazySingleton(() => AuthDataSource());
  sl.registerLazySingleton<AuthRepo>(() => AuthRepoImpl());
  sl.registerLazySingleton(() => LoginUsecase());
  sl.registerLazySingleton(() => LogoutUsecase());
  sl.registerLazySingleton(() => SignupUsecase());
  sl.registerFactory(() => LoginBloc());
  sl.registerFactory(() => SignupBloc());

  // ── Chat ────────────────────────────────────────────
  sl.registerLazySingleton(() => ChatDataSource());
  sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl());
  sl.registerLazySingleton(() => GetOrCreateConversationUsecase());
  sl.registerLazySingleton(() => GetProfilesUsecase());
  sl.registerLazySingleton(() => SendMessageUsecase());
  sl.registerLazySingleton(() => WatchMessagesUsecase());
  sl.registerFactory(() => ChatBloc());
  sl.registerFactory(() => UsersBloc());

  // ── Post ────────────────────────────────────────────
  sl.registerLazySingleton(() => PostDataSource());
  sl.registerLazySingleton<PostRepository>(() => PostRepositoryImpl());
  sl.registerLazySingleton(() => CreatePostUsecase());
  sl.registerLazySingleton(() => FetchPostsUsecase());
  sl.registerLazySingleton(() => WatchPostsUsecase());
  sl.registerFactory(() => PostBloc());
  sl.registerFactory(() => PostsListBloc());

  // ── Profile ─────────────────────────────────────────
  sl.registerLazySingleton(() => ProfileDataSource());
  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl());
  sl.registerFactory(() => ProfileBloc());
}
