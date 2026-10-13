import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/search_bloc.dart';
import '../bloc/liked_bloc.dart';
import '../widgets/track_tile.dart';
import 'liked_songs_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search() {
    FocusScope.of(context).unfocus();
    context.read<SearchBloc>().add(SearchSubmitted(_controller.text));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar en Deezer'),
        actions: [
          IconButton(
            tooltip: 'Mis canciones favoritas',
            onPressed: () {
              context.read<LikedBloc>().add(const LikedRequested());
              Navigator.pushNamed(context, LikedSongsScreen.routeName);
            },
            icon: const Icon(Icons.favorite),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          return Column(
            children: [
              if (state.status == SearchStatus.loading)
                const LinearProgressIndicator(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 850),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (_) => _search(),
                            decoration: const InputDecoration(
                              labelText: 'Artista o canción',
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        FilledButton.icon(
                          onPressed: state.status == SearchStatus.loading
                              ? null
                              : _search,
                          icon: const Icon(Icons.search),
                          label: const Text('Buscar'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(110, 56),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(child: _SearchContent(state: state)),
            ],
          );
        },
      ),
    );
  }
}

class _SearchContent extends StatelessWidget {
  const _SearchContent({required this.state});
  final SearchState state;

  @override
  Widget build(BuildContext context) {
    final likedState = context.watch<LikedBloc>().state;
    if (state.status == SearchStatus.initial) {
      return const _Message(
        icon: Icons.headphones,
        title: 'Encuentra tu próxima canción',
        detail: 'Busca por artista o por el título de una canción.',
      );
    }
    if (state.status == SearchStatus.failure) {
      return _Message(
        icon: Icons.cloud_off,
        title: 'No se pudo completar la búsqueda',
        detail: state.errorMessage ?? 'Ocurrió un error inesperado.',
      );
    }
    if (state.status == SearchStatus.success && state.tracks.isEmpty) {
      return const _Message(
        icon: Icons.search_off,
        title: 'No encontramos resultados',
        detail: 'Prueba con otro artista o canción.',
      );
    }
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 850),
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          itemCount: state.tracks.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final track = state.tracks[index];
            return TrackTile(
              track: track,
              isFavorite: likedState.favoriteIds.contains(track.id),
              isPending: likedState.pendingTrackIds.contains(track.id),
              likeEnabled:
                  likedState.status == LikedStatus.success &&
                  !likedState.pendingTrackIds.contains(track.id),
              onLike: () =>
                  context.read<LikedBloc>().add(FavoriteToggled(track)),
            );
          },
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.detail,
  });
  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 58, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            detail,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    ),
  );
}
