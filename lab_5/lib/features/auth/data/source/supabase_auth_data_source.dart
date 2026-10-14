import 'package:moviles_auth/features/auth/domain/entities/auth_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

class SupabaseAuthDataSource {
  final SupabaseClient _client;

  SupabaseAuthDataSource(this._client);

  Future<AuthUser> signUp({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw StateError('Supabase Auth did not return a user after sign up.');
    }

    final userEmail = user.email;
    if (userEmail == null) {
      throw StateError('The user returned by Supabase Auth has no email.');
    }

    return AuthUser(id: user.id, email: userEmail);
  }
}
