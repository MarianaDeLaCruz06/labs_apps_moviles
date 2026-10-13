import 'package:deezer_lab4/features/search/domain/models/favorite_collection.dart';
import 'package:deezer_lab4/features/search/domain/models/track.dart';
import 'package:deezer_lab4/features/search/domain/repository/music_repository.dart';
import 'package:deezer_lab4/features/search/domain/usecases/search_tracks_usecase.dart';
import 'package:deezer_lab4/features/search/ui/bloc/search_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

const _track = Track(
  id: 3135556,
  title: 'Bohemian Rhapsody',
  artist: 'Queen',
  albumCover: 'https://example.com/cover.jpg',
);

class _FakeMusicRepository implements MusicRepository {
  Object? searchError;
  String? receivedQuery;

  @override
  Future<List<Track>> searchTracks(String query) async {
    receivedQuery = query;
    if (searchError != null) throw searchError!;
    return const [_track];
  }

  @override
  Future<FavoriteCollection> getLikedTracks() async =>
      FavoriteCollection.empty();

  @override
  Future<String> likeTrack(Track track) async => '-firebase-key';

  @override
  Future<void> unlikeTrack(Set<String> storageKeys) async {}
}

void main() {
  test('SearchSubmitted emite loading y luego success con canciones', () async {
    final repository = _FakeMusicRepository();
    final bloc = SearchBloc(SearchTracksUseCase(repository));
    addTearDown(bloc.close);

    final states = <SearchState>[];
    final subscription = bloc.stream.listen(states.add);
    addTearDown(subscription.cancel);

    bloc.add(SearchSubmitted('Queen'));
    await bloc.stream.firstWhere(
      (state) => state.status == SearchStatus.success,
    );

    expect(repository.receivedQuery, 'Queen');
    expect(states.map((state) => state.status), [
      SearchStatus.loading,
      SearchStatus.success,
    ]);
    expect(states.last.tracks, const [_track]);
  });

  test(
    'SearchSubmitted conserva resultados previos mientras vuelve a cargar',
    () async {
      final repository = _FakeMusicRepository();
      final bloc = SearchBloc(SearchTracksUseCase(repository));
      addTearDown(bloc.close);

      bloc.add(SearchSubmitted('Queen'));
      await bloc.stream.firstWhere(
        (state) => state.status == SearchStatus.success,
      );

      bloc.add(SearchSubmitted('Bowie'));
      final loading = await bloc.stream.firstWhere(
        (state) => state.status == SearchStatus.loading,
      );

      expect(loading.tracks, const [_track]);
    },
  );

  test('SearchSubmitted emite failure cuando falla el caso de uso', () async {
    final repository = _FakeMusicRepository()
      ..searchError = Exception('sin conexión');
    final bloc = SearchBloc(SearchTracksUseCase(repository));
    addTearDown(bloc.close);

    bloc.add(SearchSubmitted('Queen'));
    final failure = await bloc.stream.firstWhere(
      (state) => state.status == SearchStatus.failure,
    );

    expect(failure.errorMessage, contains('sin conexión'));
  });
}
