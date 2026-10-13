import '../models/track.dart';
import '../repository/music_repository.dart';

class LikeTrackUseCase {
  const LikeTrackUseCase(this.repository);
  final MusicRepository repository;
  Future<String> call(Track track) => repository.likeTrack(track);
}
