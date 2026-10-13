import '../repository/music_repository.dart';

class UnlikeTrackUseCase {
  const UnlikeTrackUseCase(this.repository);

  final MusicRepository repository;

  Future<void> call(Set<String> storageKeys) =>
      repository.unlikeTrack(storageKeys);
}
