import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Avatar with the initial, the name and the @username.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.username,
  });

  final String name;
  final String username;

  @override
  Widget build(BuildContext context) {
    final initial = name.isEmpty ? '?' : name.trim()[0].toUpperCase();

    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: const BoxDecoration(
            color: AppColors.green,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 40,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 16),
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
          '@$username',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
