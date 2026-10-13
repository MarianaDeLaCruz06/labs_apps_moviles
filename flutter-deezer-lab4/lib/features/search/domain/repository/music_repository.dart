import '../models/track.dart';
import '../models/favorite_collection.dart';

abstract class MusicRepository {
  Future<List<Track>> searchTracks(String query);
  Future<String> likeTrack(Track track);
  Future<void> unlikeTrack(Set<String> storageKeys);
  Future<FavoriteCollection> getLikedTracks();
}
