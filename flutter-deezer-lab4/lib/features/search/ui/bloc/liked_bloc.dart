import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/track.dart';
import '../../domain/usecases/get_liked_tracks_usecase.dart';
import '../../domain/usecases/like_track_usecase.dart';
import '../../domain/usecases/unlike_track_usecase.dart';

sealed class LikedEvent {
  const LikedEvent();
}

class LikedRequested extends LikedEvent {
  const LikedRequested();
}

class FavoriteToggled extends LikedEvent {
  const FavoriteToggled(this.track);

  final Track track;
}

enum LikedStatus { initial, loading, success, failure }

class LikedState {
  const LikedState({
    this.status = LikedStatus.initial,
    this.tracks = const [],
    this.favoriteIds = const {},
    this.storageKeysByTrackId = const {},
    this.pendingTrackIds = const {},
    this.errorMessage,
    this.operationMessage,
    this.feedbackVersion = 0,
  });

  final LikedStatus status;
  final List<Track> tracks;
  final Set<int> favoriteIds;
  final Map<int, Set<String>> storageKeysByTrackId;
  final Set<int> pendingTrackIds;
  final String? errorMessage;
  final String? operationMessage;
  final int feedbackVersion;

  LikedState copyWith({
    LikedStatus? status,
    List<Track>? tracks,
    Set<int>? favoriteIds,
    Map<int, Set<String>>? storageKeysByTrackId,
    Set<int>? pendingTrackIds,
    String? errorMessage,
    String? operationMessage,
    int? feedbackVersion,
    bool clearError = false,
    bool clearOperationMessage = false,
  }) {
    return LikedState(
      status: status ?? this.status,
      tracks: tracks ?? this.tracks,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      storageKeysByTrackId: storageKeysByTrackId ?? this.storageKeysByTrackId,
      pendingTrackIds: pendingTrackIds ?? this.pendingTrackIds,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      operationMessage: clearOperationMessage
          ? null
          : operationMessage ?? this.operationMessage,
      feedbackVersion: feedbackVersion ?? this.feedbackVersion,
    );
  }
}

class LikedBloc extends Bloc<LikedEvent, LikedState> {
  LikedBloc({
    required this.getLikedTracks,
    required this.likeTrack,
    required this.unlikeTrack,
  }) : super(const LikedState()) {
    on<LikedRequested>(_onLikedRequested);
    on<FavoriteToggled>(_onFavoriteToggled);
  }

  final GetLikedTracksUseCase getLikedTracks;
  final LikeTrackUseCase likeTrack;
  final UnlikeTrackUseCase unlikeTrack;
  final Set<int> _operationsInFlight = {};

  Future<void> _onLikedRequested(
    LikedRequested event,
    Emitter<LikedState> emit,
  ) async {
    emit(state.copyWith(status: LikedStatus.loading, clearError: true));
    try {
      final favorites = await getLikedTracks();
      emit(
        state.copyWith(
          status: LikedStatus.success,
          tracks: favorites.tracks,
          favoriteIds: favorites.trackIds,
          storageKeysByTrackId: favorites.storageKeysByTrackId,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: LikedStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onFavoriteToggled(
    FavoriteToggled event,
    Emitter<LikedState> emit,
  ) async {
    final trackId = event.track.id;
    if (!_operationsInFlight.add(trackId)) return;

    emit(
      state.copyWith(
        pendingTrackIds: Set<int>.from(state.pendingTrackIds)..add(trackId),
        clearError: true,
        clearOperationMessage: true,
      ),
    );
    final wasFavorite = state.favoriteIds.contains(trackId);

    try {
      String? newStorageKey;
      if (wasFavorite) {
        final keys = Set<String>.from(
          state.storageKeysByTrackId[trackId] ?? const <String>{},
        );
        await unlikeTrack(keys);
      } else {
        newStorageKey = await likeTrack(event.track);
      }

      // Se toma el estado más reciente después del await para no perder el
      // resultado de otra canción que se haya procesado en paralelo.
      final nextTracks = List<Track>.from(state.tracks);
      final nextIds = Set<int>.from(state.favoriteIds);
      final nextKeys = state.storageKeysByTrackId.map(
        (id, keys) => MapEntry(id, Set<String>.from(keys)),
      );
      if (wasFavorite) {
        nextTracks.removeWhere((track) => track.id == trackId);
        nextIds.remove(trackId);
        nextKeys.remove(trackId);
      } else {
        nextTracks.add(event.track);
        nextIds.add(trackId);
        nextKeys[trackId] = {newStorageKey!};
      }

      emit(
        state.copyWith(
          status: LikedStatus.success,
          tracks: nextTracks,
          favoriteIds: nextIds,
          storageKeysByTrackId: nextKeys,
          pendingTrackIds: Set<int>.from(state.pendingTrackIds)
            ..remove(trackId),
          operationMessage: wasFavorite
              ? '“${event.track.title}” se quitó de favoritos.'
              : '“${event.track.title}” se guardó en favoritos.',
          feedbackVersion: state.feedbackVersion + 1,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          pendingTrackIds: Set<int>.from(state.pendingTrackIds)
            ..remove(trackId),
          errorMessage: error.toString(),
          feedbackVersion: state.feedbackVersion + 1,
          clearOperationMessage: true,
        ),
      );
      if (wasFavorite) add(const LikedRequested());
    } finally {
      _operationsInFlight.remove(trackId);
    }
  }
}
