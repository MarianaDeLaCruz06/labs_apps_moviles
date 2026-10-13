import 'package:deezer_lab4/features/search/domain/models/track.dart';
import 'package:deezer_lab4/features/search/domain/models/favorite_collection.dart';
import 'package:deezer_lab4/features/search/domain/repository/music_repository.dart';
import 'package:deezer_lab4/main.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeMusicRepository implements MusicRepository {
  @override
  Future<FavoriteCollection> getLikedTracks() async =>
      FavoriteCollection.empty();
  @override
  Future<String> likeTrack(Track track) async => 'firebase-key';

  @override
  Future<void> unlikeTrack(Set<String> storageKeys) async {}
  @override
  Future<List<Track>> searchTracks(String query) async => const [];
}

void main() {
  test('Track interpreta los formatos de Deezer y Firebase', () {
    final deezerTrack = Track.fromJson({
      'id': 3135556,
      'title': 'Bohemian Rhapsody',
      'artist': {'name': 'Queen'},
      'album': {'cover_medium': 'https://example.com/cover.jpg'},
    });
    expect(deezerTrack.artist, 'Queen');
    expect(deezerTrack.toJson()['albumCover'], contains('cover.jpg'));
    final likedTrack = Track.fromLikedJson(deezerTrack.toJson());
    expect(likedTrack.id, 3135556);
    expect(likedTrack.title, 'Bohemian Rhapsody');
  });

  testWidgets('muestra la pantalla inicial de búsqueda', (tester) async {
    await tester.pumpWidget(DeezerLabApp(repository: _FakeMusicRepository()));
    expect(find.text('Buscar en Deezer'), findsOneWidget);
    expect(find.text('Artista o canción'), findsOneWidget);
    expect(find.text('Encuentra tu próxima canción'), findsOneWidget);
  });
}
