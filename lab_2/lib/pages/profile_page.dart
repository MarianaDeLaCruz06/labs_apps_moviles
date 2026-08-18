import 'package:flutter/material.dart';

import '../components/info_row.dart';
import '../components/profile_header.dart';
import '../components/secondary_button.dart';
import '../models/music_profile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.profile,
    required this.onEditProfile,
    required this.onLogout,
  });

  final MusicProfile profile;
  final VoidCallback onEditProfile;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),

          ProfileHeader(
            name: profile.fullName,
            username: profile.username,
          ),

          const SizedBox(height: 36),

          InfoRow(
            label: 'Correo',
            value: profile.email,
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

          const SizedBox(height: 32),

          SecondaryButton(
            text: 'Editar perfil',
            onPressed: onEditProfile,
            fullWidth: true,
          ),

          const SizedBox(height: 12),

          SecondaryButton(
            text: 'Cerrar sesión',
            onPressed: onLogout,
            fullWidth: true,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}