import 'dart:async';

import 'package:deezer_lab4/features/search/domain/models/favorite_collection.dart';
import 'package:deezer_lab4/features/search/domain/models/track.dart';
import 'package:deezer_lab4/features/search/domain/repository/music_repository.dart';
import 'package:deezer_lab4/features/search/domain/usecases/get_liked_tracks_usecase.dart';
import 'package:deezer_lab4/features/search/domain/usecases/like_track_usecase.dart';
import 'package:deezer_lab4/features/search/domain/usecases/unlike_track_usecase.dart';
import 'package:deezer_lab4/features/search/ui/bloc/liked_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

const _track = Track(
  id: 3135556,
  title: 'Bohemian Rhapsody',
  artist: 'Queen',
  albumCover: '',
);

class _FakeRepository implements MusicRepository {
  FavoriteCollection favorites = FavoriteCollection.empty();
  Completer<String>? pendingLike;
  Object? likeError;
  int likeCalls = 0;
  int unlikeCalls = 0;
  Set<String>? deletedKeys;

  @override
  Future<FavoriteCollection> getLikedTracks() async => favorites;

  @override
  Future<String> likeTrack(Track track) async {
    likeCalls++;
    if (likeError != null) throw likeError!;
    if (pendingLike != null) return pendingLike!.future;
    return '-new-key';
  }

  @override
  Future<void> unlikeTrack(Set<String> storageKeys) async {
    unlikeCalls++;
    deletedKeys = storageKeys;
  }

  @override
  Future<List<Track>> searchTracks(String query) async => const [];
}

LikedBloc _buildBloc(_FakeRepository repository) => LikedBloc(
  getLikedTracks: GetLikedTracksUseCase(repository),
  likeTrack: LikeTrackUseCase(repository),
  unlikeTrack: UnlikeTrackUseCase(repository),
);

void main() {
  test('agrega una canción y registra la clave Firebase', () async {
    final repository = _FakeRepository();
    final bloc = _buildBloc(repository);
    addTearDown(bloc.close);

    bloc.add(const FavoriteToggled(_track));
    final state = await bloc.stream.firstWhere(
      (state) => state.favoriteIds.contains(_track.id),
    );

    expect(repository.likeCalls, 1);
    expect(state.storageKeysByTrackId[_track.id], {'-new-key'});
  });

  test('doble pulsación durante POST solo ejecuta una operación', () async {
    final repository = _FakeRepository()..pendingLike = Completer<String>();
    final bloc = _buildBloc(repository);
    addTearDown(bloc.close);

    bloc
      ..add(const FavoriteToggled(_track))
      ..add(const FavoriteToggled(_track));
    await bloc.stream.firstWhere((state) => state.pendingTrackIds.isNotEmpty);
    await Future<void>.delayed(Duration.zero);
    expect(repository.likeCalls, 1);

    repository.pendingLike!.complete('-one-key');
    await bloc.stream.firstWhere((state) => state.favoriteIds.isNotEmpty);
    expect(repository.likeCalls, 1);
  });

  test('quitar favorito elimina todas las claves duplicadas', () async {
    final repository = _FakeRepository()
      ..favorites = FavoriteCollection(
        tracksById: {_track.id: _track},
        storageKeysByTrackId: {
          _track.id: {'-old-a', '-old-b'},
        },
      );
    final bloc = _buildBloc(repository);
    addTearDown(bloc.close);

    bloc.add(const LikedRequested());
    await bloc.stream.firstWhere((state) => state.favoriteIds.isNotEmpty);
    bloc.add(const FavoriteToggled(_track));
    final empty = await bloc.stream.firstWhere(
      (state) =>
          state.status == LikedStatus.success && state.favoriteIds.isEmpty,
    );

    expect(repository.unlikeCalls, 1);
    expect(repository.deletedKeys, {'-old-a', '-old-b'});
    expect(empty.tracks, isEmpty);
  });

  test('fallo al guardar no marca el corazón ni borra resultados', () async {
    final repository = _FakeRepository()..likeError = Exception('sin permiso');
    final bloc = _buildBloc(repository);
    addTearDown(bloc.close);

    bloc.add(const FavoriteToggled(_track));
    final failed = await bloc.stream.firstWhere(
      (state) => state.errorMessage != null,
    );

    expect(failed.favoriteIds, isEmpty);
    expect(failed.tracks, isEmpty);
    expect(failed.pendingTrackIds, isEmpty);
  });
}
