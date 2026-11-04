import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:moviles_auth/components/avatar.dart';
import 'package:moviles_auth/features/posts/domain/entities/post.dart';
import 'package:moviles_auth/theme/app_theme.dart';

enum _PostAction { delete }

/// Card of one post: author, text, image, date and likes.
class PostCard extends StatelessWidget {
  final Post post;
  final Function() onLike;
  final VoidCallback? onDelete;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    this.onDelete,
  });

  String _date(DateTime date) {
    final local = date.toLocal();
    final minutes = local.minute.toString().padLeft(2, '0');

    return '${local.day}/${local.month} · ${local.hour}:$minutes';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Avatar(
                url: post.authorAvatarUrl,
                name: post.authorName,
                size: 40,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@${post.authorUsername}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      post.authorName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _date(post.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              if (post.isMine && onDelete != null)
                PopupMenuButton<_PostAction>(
                  tooltip: 'Opciones de la publicación',
                  onSelected: (action) {
                    if (action == _PostAction.delete) onDelete!();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem<_PostAction>(
                      value: _PostAction.delete,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.delete_outline, color: AppColors.error),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Eliminar publicación',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),

          if (post.content.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              post.content,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
          ],

          if (post.imageUrl != null) ...[
            const SizedBox(height: 12),

            // Imagen completa y proporcional.
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                color: AppColors.background,
                child: CachedNetworkImage(
                  imageUrl: post.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  placeholder: (context, url) => const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Icon(Icons.broken_image_outlined)),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 8),

          Row(
            children: [
              IconButton(
                onPressed: onLike,
                icon: Icon(
                  post.likedByMe ? Icons.favorite : Icons.favorite_border,
                  color: AppColors.primaryDark,
                ),
              ),
              Text(
                '${post.likeCount}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
