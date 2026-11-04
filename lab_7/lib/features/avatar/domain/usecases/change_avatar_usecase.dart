import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/repository/auth_repository.dart';
import 'package:moviles_auth/features/auth/domain/repository/profile_repository.dart';

import 'package:moviles_auth/features/auth/data/repository/auth_repository_impl.dart';
import 'package:moviles_auth/features/auth/data/repository/profile_repository_impl.dart';

import 'package:moviles_auth/features/avatar/domain/entities/photo_source.dart';
import 'package:moviles_auth/features/avatar/domain/repository/avatar_repository.dart';
import 'package:moviles_auth/features/avatar/data/repository/avatar_repository_impl.dart';

/// Uploads a new profile photo, saves its path and removes the old photo.
class ChangeAvatarUseCase {
  static const maxBytes = 2 * 1024 * 1024;

  final AuthRepository _auth = AuthRepositoryImpl();
  final ProfileRepository _profiles = ProfileRepositoryImpl();
  final AvatarRepository _avatars = AvatarRepositoryImpl();

  Future<Profile?> call({PhotoSource source = PhotoSource.gallery}) async {
    final user = _auth.currentUser();

    if (user == null) {
      throw Exception('No hay una sesión iniciada');
    }

    // Choose the photo from the selected source.
    final photo = await _avatars.pick(source: source);

    // Cancelling does not change the existing avatar.
    if (photo == null) return null;

    if (photo.bytes.length > maxBytes) {
      throw Exception('La foto pesa más de 2 MB');
    }

    // Remember the previous photo.
    final before = await _profiles.getProfile(user.id);

    // Upload before updating the database.
    final path = await _avatars.upload(photo);

    await _profiles.updateAvatarPath(user.id, path);

    // Remove the previous photo only after saving the new path.
    final oldPath = before.avatarPath;

    if (oldPath != null && oldPath != path) {
      await _avatars.remove(oldPath);
    }

    return _profiles.getProfile(user.id);
  }
}
