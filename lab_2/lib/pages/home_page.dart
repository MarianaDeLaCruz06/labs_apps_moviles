import 'package:flutter/material.dart';

import '../components/highlight_card.dart';
import '../components/playlist_card.dart';
import '../models/music_profile.dart';
import '../theme/app_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.profile,
  });

  final MusicProfile profile;

  @override
  Widget build(BuildContext context) {
    final firstName = profile.fullName.trim().isEmpty
        ? 'Usuario'
        : profile.fullName.trim().split(' ').first;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hola, $firstName',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Tu mood de hoy: ${profile.mood}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 36),

          const Text(
            'Tu playlist',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          PlaylistCard(
            name: profile.playlistName,
            mood: profile.mood,
            coverUrl: profile.coverUrl,
          ),

          const SizedBox(height: 36),

          const Text(
            'Basado en tus gustos',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          HighlightCard(
            title: 'Radio ${profile.favoriteArtist}',
            subtitle: 'Canciones parecidas a lo que te gusta',
          ),
        ],
      ),
    );
  }
}