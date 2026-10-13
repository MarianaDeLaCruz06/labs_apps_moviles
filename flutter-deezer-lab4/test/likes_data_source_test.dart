import 'dart:convert';

import 'package:deezer_lab4/features/search/data/sources/likes_data_source.dart';
import 'package:deezer_lab4/features/search/domain/models/track.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _track = Track(
  id: 3135556,
  title: 'Bohemian Rhapsody',
  artist: 'Queen',
  albumCover: 'https://example.com/cover.jpg',
);

void main() {
  test('POST devuelve y conserva la clave generada por Firebase', () async {
    final source = LikesDataSource(
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(jsonDecode(request.body)['id'], _track.id);
        return http.Response(jsonEncode({'name': '-firebase-key'}), 200);
      }),
    );

    expect(await source.saveTrack(_track), '-firebase-key');
  });

  test('GET deduplica por ID y conserva todas las claves Firebase', () async {
    final source = LikesDataSource(
      client: MockClient((_) async {
        return http.Response(
          jsonEncode({
            '-key-a': _track.toJson(),
            '-key-b': _track.toJson(),
            '-key-c': const Track(
              id: 2,
              title: 'Another One Bites the Dust',
              artist: 'Queen',
              albumCover: '',
            ).toJson(),
          }),
          200,
        );
      }),
    );

    final favorites = await source.getLikedTracks();
    expect(favorites.tracks, hasLength(2));
    expect(favorites.trackIds, {_track.id, 2});
    expect(favorites.storageKeysByTrackId[_track.id], {'-key-a', '-key-b'});
  });

  test('DELETE elimina cada duplicado mediante su URL individual', () async {
    final deletedPaths = <String>[];
    final source = LikesDataSource(
      client: MockClient((request) async {
        expect(request.method, 'DELETE');
        deletedPaths.add(request.url.path);
        return http.Response('null', 200);
      }),
    );

    await source.deleteTracks({'-key-a', '-key-b'});
    expect(deletedPaths, hasLength(2));
    expect(deletedPaths.every((path) => path.endsWith('.json')), isTrue);
    expect(deletedPaths.any((path) => path.contains('-key-a')), isTrue);
    expect(deletedPaths.any((path) => path.contains('-key-b')), isTrue);
  });

  test('un error HTTP de DELETE se informa', () async {
    final source = LikesDataSource(
      client: MockClient((_) async => http.Response('Permission denied', 401)),
    );

    expect(() => source.deleteTracks({'-key'}), throwsA(isA<LikesException>()));
  });
}
