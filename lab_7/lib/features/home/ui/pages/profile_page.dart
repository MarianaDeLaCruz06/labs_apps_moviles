import 'package:flutter/material.dart';

import 'package:moviles_auth/components/avatar.dart';
import 'package:moviles_auth/components/primary_button.dart';
import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/home/ui/components/post_card.dart';
import 'package:moviles_auth/features/posts/domain/entities/post.dart';
import 'package:moviles_auth/theme/app_theme.dart';

/// The profile of the signed in user, their photo and their latest posts.
class ProfilePage extends StatelessWidget {
  final Profile profile;
  final List<Post> posts;
  final bool isUploading;
  final Function() onChangePhoto;
  final Function(Post) onLike;
  final Function() onSignOut;
  final VoidCallback onRemovePhoto;
  final Function(Post) onDelete;

  const ProfilePage({
    super.key,
    required this.profile,
    required this.posts,
    required this.isUploading,
    required this.onChangePhoto,
    required this.onLike,
    required this.onSignOut,
    required this.onRemovePhoto,
    required this.onDelete,
  });

  Widget _photo() {
    return SizedBox(
      width: 104,
      height: 104,
      child: Stack(
        children: [
          Avatar(url: profile.avatarUrl, name: profile.fullName, size: 104),

          if (isUploading)
            Container(
              width: 104,
              height: 104,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.black38,
                shape: BoxShape.circle,
              ),
              child: const CircularProgressIndicator(color: AppColors.surface),
            ),

          Positioned(
            right: 0,
            bottom: 0,
            child: IconButton.filled(
              onPressed: isUploading ? null : onChangePhoto,
              icon: const Icon(Icons.photo_camera_outlined),
              tooltip: 'Cambiar foto',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: _photo()),

          const SizedBox(height: 16),

          Text(
            profile.fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            '@${profile.username}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),

          // RETO 3: Quitar la fotografía del perfil.
          if (profile.avatarPath != null) ...[
            const SizedBox(height: 12),

            Center(
              child: TextButton.icon(
                onPressed: isUploading ? null : onRemovePhoto,
                icon: const Icon(Icons.delete_outline, size: 19),
                label: const Text('Quitar foto de perfil'),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
              ),
            ),
          ],

          const SizedBox(height: 32),

          const Text(
            'Tus últimos posts',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          if (posts.isEmpty)
            const Text(
              'Aún no has publicado',
              style: TextStyle(color: AppColors.textSecondary),
            ),

          for (final post in posts)
            PostCard(
              post: post,
              onLike: () => onLike(post),
              onDelete: () => onDelete(post),
            ),

          const SizedBox(height: 24),

          PrimaryButton(label: 'Cerrar sesión', onPressed: onSignOut),
        ],
      ),
    );
  }
}
