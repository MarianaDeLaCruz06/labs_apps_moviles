import 'package:flutter/material.dart';

import '../models/music_profile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.profile,
  });

  final MusicProfile profile;

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('TODO part 6'),
    );
  }
}