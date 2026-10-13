import '../models/favorite_collection.dart';
import '../repository/music_repository.dart';

class GetLikedTracksUseCase {
  const GetLikedTracksUseCase(this.repository);
  final MusicRepository repository;
  Future<FavoriteCollection> call() => repository.getLikedTracks();
}
