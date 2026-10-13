import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'features/search/data/repository/music_repository_impl.dart';
import 'features/search/data/sources/deezer_data_source.dart';
import 'features/search/data/sources/likes_data_source.dart';
import 'features/search/domain/repository/music_repository.dart';
import 'features/search/domain/usecases/get_liked_tracks_usecase.dart';
import 'features/search/domain/usecases/like_track_usecase.dart';
import 'features/search/domain/usecases/search_tracks_usecase.dart';
import 'features/search/domain/usecases/unlike_track_usecase.dart';
import 'features/search/ui/bloc/liked_bloc.dart';
import 'features/search/ui/bloc/search_bloc.dart';
import 'features/search/ui/screens/liked_songs_screen.dart';
import 'features/search/ui/screens/search_screen.dart';

void main() {
  final client = http.Client();
  final repository = MusicRepositoryImpl(
    DeezerDataSource(client: client),
    LikesDataSource(client: client),
  );
  runApp(DeezerLabApp(repository: repository));
}

class DeezerLabApp extends StatelessWidget {
  const DeezerLabApp({super.key, required this.repository});

  final MusicRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deezer Lab 4',
      debugShowCheckedModeBanner: false,
      builder: (context, child) => BlocProvider(
        create: (_) => LikedBloc(
          getLikedTracks: GetLikedTracksUseCase(repository),
          likeTrack: LikeTrackUseCase(repository),
          unlikeTrack: UnlikeTrackUseCase(repository),
        )..add(const LikedRequested()),
        child: _FavoriteFeedback(child: child!),
      ),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        scaffoldBackgroundColor: const Color(0xFFF6F8FC),
        cardTheme: const CardThemeData(
          elevation: 1,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
      ),
      home: BlocProvider(
        create: (_) => SearchBloc(SearchTracksUseCase(repository)),
        child: const SearchScreen(),
      ),
      onGenerateRoute: (settings) {
        if (settings.name == LikedSongsScreen.routeName) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (routeContext) => BlocProvider.value(
              value: routeContext.read<LikedBloc>(),
              /* create: (_) =>
                  LikedBloc(getLikedTracks: GetLikedTracksUseCase(repository))
                    ..add(const LikedRequested()),
              */
              child: const LikedSongsScreen(),
            ),
          );
        }
        return null;
      },
    );
  }
}

class _FavoriteFeedback extends StatelessWidget {
  const _FavoriteFeedback({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<LikedBloc, LikedState>(
      listenWhen: (previous, current) =>
          previous.feedbackVersion != current.feedbackVersion,
      listener: (context, state) {
        final message = state.errorMessage ?? state.operationMessage;
        if (message == null) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: state.errorMessage == null
                  ? Colors.green.shade700
                  : Theme.of(context).colorScheme.error,
            ),
          );
      },
      child: child,
    );
  }
}
