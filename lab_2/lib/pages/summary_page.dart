import 'package:flutter/material.dart';

import '../components/info_row.dart';
import '../components/primary_button.dart';
import '../models/music_profile.dart';
import '../theme/app_theme.dart';

class SummaryPage extends StatelessWidget {
  const SummaryPage({
    super.key,
    required this.profile,
    required this.onStart,
  });

  final MusicProfile profile;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),

          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.black,
                size: 36,
              ),
            ),
          ),

          const SizedBox(height: 28),

          const Text(
            'Así te vamos a conocer',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Puedes cambiar esto después en tu perfil',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 36),

          InfoRow(
            label: 'Correo',
            value: profile.email,
          ),

          InfoRow(
            label: 'Nombre',
            value: profile.fullName,
          ),

          InfoRow(
            label: 'Usuario',
            value: '@${profile.username}',
          ),

          InfoRow(
            label: 'Artista favorito',
            value: profile.favoriteArtist,
          ),

          InfoRow(
            label: 'Mood',
            value: profile.mood,
          ),

          InfoRow(
            label: 'Playlist',
            value: profile.playlistName,
          ),

          const SizedBox(height: 40),

          PrimaryButton(
            text: 'Empezar a escuchar',
            onPressed: onStart,
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}