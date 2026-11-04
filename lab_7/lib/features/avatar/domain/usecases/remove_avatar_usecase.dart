import 'package:moviles_auth/features/auth/data/repository/auth_repository_impl.dart';
import 'package:moviles_auth/features/auth/data/repository/profile_repository_impl.dart';
import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/repository/auth_repository.dart';
import 'package:moviles_auth/features/auth/domain/repository/profile_repository.dart';
import 'package:moviles_auth/features/avatar/data/repository/avatar_repository_impl.dart';
import 'package:moviles_auth/features/avatar/domain/repository/avatar_repository.dart';

/// Removes the current profile photo.
class RemoveAvatarUseCase {
  final AuthRepository _auth;
  final ProfileRepository _profiles;
  final AvatarRepository _avatars;

  RemoveAvatarUseCase({
    AuthRepository? auth,
    ProfileRepository? profiles,
    AvatarRepository? avatars,
  }) : _auth = auth ?? AuthRepositoryImpl(),
       _profiles = profiles ?? ProfileRepositoryImpl(),
       _avatars = avatars ?? AvatarRepositoryImpl();

  Future<Profile> call() async {
    final user = _auth.currentUser();

    if (user == null) {
      throw Exception('No hay una sesión iniciada');
    }

    final profile = await _profiles.getProfile(user.id);
    final oldPath = profile.avatarPath;

    // No photo to remove.
    if (oldPath == null) {
      return profile;
    }

    if (!oldPath.startsWith('${user.id}/')) {
      throw Exception('La ruta del avatar no pertenece al usuario autenticado');
    }

    // First remove the reference in the database.
    await _profiles.updateAvatarPath(user.id, null);

    // Then remove the file from Storage.
    try {
      await _avatars.remove(oldPath);
    } on Exception catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      throw Exception(
        'La foto se quitó del perfil, pero no se pudo borrar el archivo de '
        'Storage; puede quedar un archivo huérfano. $message',
      );
    }

    return _profiles.getProfile(user.id);
  }
}
