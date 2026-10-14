import 'package:moviles_auth/features/auth/domain/entities/auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser> signUp({required String email, required String password});
}
