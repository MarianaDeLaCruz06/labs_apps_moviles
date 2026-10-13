import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/models/track.dart';
import '../../domain/models/favorite_collection.dart';

class LikesDataSource {
  LikesDataSource({required this.client});
  static final _likesUri = Uri.parse(
    'https://facelogprueba.firebaseio.com/playlist/marianadelacruz06.json',
  );
  final http.Client client;

  Future<String> saveTrack(Track track) async {
    try {
      final response = await client.post(
        _likesUri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(track.toJson()),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw LikesException(
          'Firebase rechazó el guardado con el código ${response.statusCode}: ${response.body}',
        );
      }
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic> || decoded['name'] is! String) {
        throw const LikesException(
          'Firebase guardó la canción, pero no devolvió su clave.',
        );
      }
      return decoded['name'] as String;
    } on LikesException {
      rethrow;
    } catch (error) {
      throw LikesException('No fue posible guardar en Firebase: $error');
    }
  }

  Future<FavoriteCollection> getLikedTracks() async {
    try {
      final response = await client.get(_likesUri);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw LikesException(
          'Firebase rechazó la consulta con el código ${response.statusCode}: ${response.body}',
        );
      }
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded == null) return FavoriteCollection.empty();
      if (decoded is! Map<String, dynamic>) {
        throw const LikesException('La respuesta de Firebase no es válida.');
      }
      final tracksById = <int, Track>{};
      final keysByTrackId = <int, Set<String>>{};
      for (final entry in decoded.entries) {
        final value = entry.value;
        if (value is! Map<String, dynamic>) continue;
        final track = Track.fromLikedJson(value);
        tracksById.putIfAbsent(track.id, () => track);
        (keysByTrackId[track.id] ??= <String>{}).add(entry.key);
      }
      return FavoriteCollection(
        tracksById: tracksById,
        storageKeysByTrackId: keysByTrackId,
      );
    } on LikesException {
      rethrow;
    } catch (error) {
      throw LikesException('No fue posible consultar Firebase: $error');
    }
  }

  Future<void> deleteTracks(Set<String> storageKeys) async {
    if (storageKeys.isEmpty) {
      throw const LikesException(
        'No se encontró la clave de Firebase para eliminar la canción.',
      );
    }

    // Cada DELETE apunta exclusivamente a una clave. Nunca se elimina el nodo
    // completo de la playlist.
    for (final storageKey in storageKeys) {
      final uri = Uri.parse(
        'https://facelogprueba.firebaseio.com/playlist/'
        'marianadelacruz06/${Uri.encodeComponent(storageKey)}.json',
      );
      try {
        final response = await client.delete(uri);
        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw LikesException(
            'Firebase rechazó la eliminación con el código '
            '${response.statusCode}: ${response.body}',
          );
        }
      } on LikesException {
        rethrow;
      } catch (error) {
        throw LikesException('No fue posible eliminar de Firebase: $error');
      }
    }
  }
}

class LikesException implements Exception {
  const LikesException(this.message);
  final String message;
  @override
  String toString() => message;
}
