import 'package:flutter/material.dart';

import '../components/info_row.dart';
import '../components/playlist_hero.dart';
import '../models/music_profile.dart';

class PlaylistPage extends StatelessWidget {
  const PlaylistPage({
    super.key,
    required this.profile,
  });

  final MusicProfile profile;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),

          PlaylistHero(
            name: profile.playlistName,
            mood: profile.mood,
            coverUrl: profile.coverUrl,
          ),

          const SizedBox(height: 36),

          InfoRow(
            label: 'Creada por',
            value: '@${profile.username}',
          ),

          InfoRow(
            label: 'Inspirada en',
            value: profile.favoriteArtist,
          ),
        ],
      ),
    );
  }
}