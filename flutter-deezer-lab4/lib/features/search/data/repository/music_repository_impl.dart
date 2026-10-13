import '../../domain/models/track.dart';
import '../../domain/models/favorite_collection.dart';
import '../../domain/repository/music_repository.dart';
import '../sources/deezer_data_source.dart';
import '../sources/likes_data_source.dart';

class MusicRepositoryImpl implements MusicRepository {
  const MusicRepositoryImpl(this._deezerDataSource, this._likesDataSource);

  final DeezerDataSource _deezerDataSource;
  final LikesDataSource _likesDataSource;

  @override
  Future<List<Track>> searchTracks(String query) =>
      _deezerDataSource.searchTracks(query);

  @override
  Future<String> likeTrack(Track track) => _likesDataSource.saveTrack(track);

  @override
  Future<void> unlikeTrack(Set<String> storageKeys) =>
      _likesDataSource.deleteTracks(storageKeys);

  @override
  Future<FavoriteCollection> getLikedTracks() =>
      _likesDataSource.getLikedTracks();
}
