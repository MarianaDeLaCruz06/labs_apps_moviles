import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/track.dart';
import '../../domain/usecases/search_tracks_usecase.dart';

abstract class SearchEvent {}

class SearchSubmitted extends SearchEvent {
  final String query;

  SearchSubmitted(this.query);
}

enum SearchStatus { initial, loading, success, failure }

class SearchState {
  const SearchState({
    this.status = SearchStatus.initial,
    this.tracks = const [],
    this.errorMessage,
  });

  final SearchStatus status;
  final List<Track> tracks;
  final String? errorMessage;

  SearchState copyWith({
    SearchStatus? status,
    List<Track>? tracks,
    String? errorMessage,
  }) {
    return SearchState(
      status: status ?? this.status,
      tracks: tracks ?? this.tracks,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(this._searchTracks) : super(const SearchState()) {
    on<SearchSubmitted>(_onSubmitted);
  }

  final SearchTracksUseCase _searchTracks;

  Future<void> _onSubmitted(
    SearchSubmitted event,
    Emitter<SearchState> emit,
  ) async {
    emit(state.copyWith(status: SearchStatus.loading));
    try {
      final tracks = await _searchTracks(event.query);
      emit(state.copyWith(status: SearchStatus.success, tracks: tracks));
    } on Exception catch (error) {
      emit(
        state.copyWith(
          status: SearchStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
