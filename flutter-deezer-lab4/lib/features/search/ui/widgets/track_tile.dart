import 'package:flutter/material.dart';

import '../../domain/models/track.dart';

class TrackTile extends StatelessWidget {
  const TrackTile({
    super.key,
    required this.track,
    this.onLike,
    this.likeEnabled = true,
    this.isFavorite = false,
    this.isPending = false,
  });

  final Track track;
  final VoidCallback? onLike;
  final bool likeEnabled;
  final bool isFavorite;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox.square(
                dimension: 76,
                child: track.albumCover.isEmpty
                    ? _coverPlaceholder()
                    : Image.network(
                        track.albumCover,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _coverPlaceholder(),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    track.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: Colors.black54),
                  ),
                ],
              ),
            ),
            if (onLike != null)
              IconButton.filledTonal(
                tooltip: isFavorite
                    ? 'Quitar de favoritos'
                    : 'Guardar en favoritos',
                onPressed: likeEnabled ? onLike : null,
                icon: isPending
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : null,
                      ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _coverPlaceholder() => Container(
    color: const Color(0xFFE2E8F0),
    child: const Icon(Icons.music_note, color: Colors.blueGrey, size: 34),
  );
}
