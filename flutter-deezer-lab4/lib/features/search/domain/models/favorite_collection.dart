import 'track.dart';

/// Vista de favoritos deduplicada por el ID real de Deezer.
///
/// Las claves de almacenamiento se conservan separadas del modelo [Track]
/// porque solo son necesarias para eliminar registros concretos de Firebase.
class FavoriteCollection {
  FavoriteCollection({
    required Map<int, Track> tracksById,
    required Map<int, Set<String>> storageKeysByTrackId,
  }) : tracksById = Map.unmodifiable(tracksById),
       storageKeysByTrackId = Map.unmodifiable(
         storageKeysByTrackId.map(
           (id, keys) => MapEntry(id, Set.unmodifiable(keys)),
         ),
       );

  factory FavoriteCollection.empty() =>
      FavoriteCollection(tracksById: const {}, storageKeysByTrackId: const {});

  final Map<int, Track> tracksById;
  final Map<int, Set<String>> storageKeysByTrackId;

  List<Track> get tracks => List.unmodifiable(tracksById.values);
  Set<int> get trackIds => Set.unmodifiable(tracksById.keys);

  FavoriteCollection adding(Track track, String storageKey) {
    final nextTracks = Map<int, Track>.from(tracksById)..[track.id] = track;
    final nextKeys = storageKeysByTrackId.map(
      (id, keys) => MapEntry(id, Set<String>.from(keys)),
    );
    (nextKeys[track.id] ??= <String>{}).add(storageKey);
    return FavoriteCollection(
      tracksById: nextTracks,
      storageKeysByTrackId: nextKeys,
    );
  }

  FavoriteCollection removing(int trackId) {
    final nextTracks = Map<int, Track>.from(tracksById)..remove(trackId);
    final nextKeys = storageKeysByTrackId.map(
      (id, keys) => MapEntry(id, Set<String>.from(keys)),
    )..remove(trackId);
    return FavoriteCollection(
      tracksById: nextTracks,
      storageKeysByTrackId: nextKeys,
    );
  }
}
