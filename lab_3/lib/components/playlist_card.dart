import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'playlist_cover.dart';

/// Horizontal row with the cover, name and mood of a playlist.
class PlaylistCard extends StatelessWidget {
  const PlaylistCard({
    super.key,
    required this.name,
    required this.mood,
    this.coverUrl,
  });

  final String name;
  final String mood;
  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          PlaylistCover(url: coverUrl, size: 64),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'Sin nombre' : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Playlist · ${mood.isEmpty ? 'Sin mood' : mood}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
