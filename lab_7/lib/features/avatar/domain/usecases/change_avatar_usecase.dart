
import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/repository/auth_repository.dart';
import 'package:moviles_auth/features/auth/domain/repository/profile_repository.dart';

import 'package:moviles_auth/features/auth/data/repository/auth_repository_impl.dart';
import 'package:moviles_auth/features/auth/data/repository/profile_repository_impl.dart';

import 'package:moviles_auth/features/avatar/domain/repository/avatar_repository.dart';
import 'package:moviles_auth/features/avatar/data/repository/avatar_repository_impl.dart';

/// Uploads a new profile photo, points the profile to it
/// and deletes the old one.
class ChangeAvatarUseCase {
  static const maxBytes = 2 * 1024 * 1024;

  final AuthRepository _auth = AuthRepositoryImpl();
  final ProfileRepository _profiles = ProfileRepositoryImpl();
  final AvatarRepository _avatars = AvatarRepositoryImpl();

  Future<Profile?> call() async {
    // 1. Verificar que exista una sesión iniciada.
    final user = _auth.currentUser();

    if (user == null) {
      throw Exception('No hay una sesión iniciada');
    }

    // 2. Abrir la galería y seleccionar una fotografía.
    final photo = await _avatars.pick();

    // Si cancela, no hacemos ningún cambio.
    if (photo == null) return null;

    // 3. Validar el tamaño máximo de 2 MB.
    if (photo.bytes.length > maxBytes) {
      throw Exception('La foto pesa más de 2 MB');
    }

    // 4. Consultar el perfil y recordar la foto anterior.
    final before = await _profiles.getProfile(user.id);

    // 5. Subir la fotografía nueva a Supabase Storage.
    final path = await _avatars.upload(photo);

    // 6. Actualizar la ruta de la fotografía en profiles.
    await _profiles.updateAvatarPath(user.id, path);

    // 7. Eliminar la fotografía anterior, si existe.
    final oldPath = before.avatarPath;

    if (oldPath != null) {
      await _avatars.remove(oldPath);
    }

    // 8. Devolver el perfil actualizado.
    return _profiles.getProfile(user.id);
  }
}
