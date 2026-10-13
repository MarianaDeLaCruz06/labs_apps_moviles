import '../models/track.dart';
import '../repository/music_repository.dart';

class SearchTracksUseCase {
  const SearchTracksUseCase(this._repository);

  final MusicRepository _repository;

  Future<List<Track>> call(String query) => _repository.searchTracks(query);
}
