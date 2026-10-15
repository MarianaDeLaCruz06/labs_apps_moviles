import 'package:moviles_auth/features/auth/domain/entities/auth_user.dart';
import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/repository/auth_repository.dart';
import 'package:moviles_auth/features/auth/domain/repository/profile_repository.dart';

class SignInResult {
  final AuthUser user;
  final Profile profile;

  const SignInResult({required this.user, required this.profile});
}

class SignInUseCase {
  final AuthRepository _auth;
  final ProfileRepository _profiles;

  SignInUseCase(this._auth, this._profiles);

  Future<SignInResult> call({
    required String email,
    required String password,
  }) async {
    final user = await _auth.signIn(email: email, password: password);

    try {
      final profile = await _profiles.getProfile(user.id);
      return SignInResult(user: user, profile: profile);
    } catch (_) {
      try {
        await _auth.signOut();
      } catch (_) {
        // Preserve the original profile retrieval error.
      }
      rethrow;
    }
  }
}
