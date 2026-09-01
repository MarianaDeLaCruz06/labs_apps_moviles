import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'playlist_cover.dart';

/// Large centered presentation of a playlist.
class PlaylistHero extends StatelessWidget {
  const PlaylistHero({
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
    return Column(
      children: [
        PlaylistCover(url: coverUrl, size: 220),
        const SizedBox(height: 24),
        Text(
          name.isEmpty ? 'Sin nombre' : name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Playlist · ${mood.isEmpty ? 'Sin mood' : mood}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
