import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/liked_bloc.dart';
import '../widgets/track_tile.dart';

class LikedSongsScreen extends StatelessWidget {
  const LikedSongsScreen({super.key});
  static const routeName = '/liked';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis canciones favoritas'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: () =>
                context.read<LikedBloc>().add(const LikedRequested()),
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<LikedBloc, LikedState>(
        builder: (context, state) {
          return Column(
            children: [
              if (state.status == LikedStatus.loading)
                const LinearProgressIndicator(),
              Expanded(child: _LikedContent(state: state)),
            ],
          );
        },
      ),
    );
  }
}

class _LikedContent extends StatelessWidget {
  const _LikedContent({required this.state});
  final LikedState state;

  @override
  Widget build(BuildContext context) {
    if (state.status == LikedStatus.initial ||
        state.status == LikedStatus.loading && state.tracks.isEmpty) {
      return const SizedBox.shrink();
    }
    if (state.status == LikedStatus.failure) {
      return _LikedMessage(
        icon: Icons.cloud_off,
        title: 'No se pudieron consultar tus favoritos',
        detail: state.errorMessage ?? 'Ocurrió un error inesperado.',
        onRetry: () => context.read<LikedBloc>().add(const LikedRequested()),
      );
    }
    if (state.tracks.isEmpty) {
      return const _LikedMessage(
        icon: Icons.favorite_border,
        title: 'Todavía no tienes favoritos',
        detail: 'Guarda canciones desde la pantalla de búsqueda.',
      );
    }
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 850),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: state.tracks.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final track = state.tracks[index];
            final isPending = state.pendingTrackIds.contains(track.id);
            return TrackTile(
              track: track,
              isFavorite: true,
              isPending: isPending,
              likeEnabled: !isPending && state.status != LikedStatus.loading,
              onLike: () =>
                  context.read<LikedBloc>().add(FavoriteToggled(track)),
            );
          },
        ),
      ),
    );
  }
}

class _LikedMessage extends StatelessWidget {
  const _LikedMessage({
    required this.icon,
    required this.title,
    required this.detail,
    this.onRetry,
  });
  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback? onRetry;

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
          Text(detail, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ],
      ),
    ),
  );
}
