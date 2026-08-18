import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Square playlist cover. Falls back to an icon if the URL fails.
class PlaylistCover extends StatelessWidget {
  const PlaylistCover({super.key, this.url, this.size = 64});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final source = url ?? '';

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: source.isEmpty
          ? _placeholder()
          : Image.network(
              source,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _placeholder(),
            ),
    );
  }

  Widget _placeholder() {
    return Icon(
      Icons.music_note,
      color: AppColors.textSecondary,
      size: size * 0.4,
    );
  }
}
