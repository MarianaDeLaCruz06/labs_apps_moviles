import 'dart:developer' as developer;

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
    developer.log('Auth sign-up request completed.', name: 'registration');

    final user = response.user;
    if (user == null) {
      throw StateError('Supabase Auth did not return a user after sign up.');
    }

    final session = response.session;
    final currentSession = _client.auth.currentSession;
    if (session == null ||
        currentSession == null ||
        currentSession.user.id != user.id) {
      developer.log(
        'Auth sign-up did not establish the required authenticated session.',
        name: 'registration',
        level: 1000,
      );
      throw StateError(
        'Supabase Auth created the user but did not establish an '
        'authenticated session. Verify the email confirmation settings.',
      );
    }
    developer.log(
      'Authenticated session is available for profile creation.',
      name: 'registration',
    );

    final userEmail = user.email;
    if (userEmail == null) {
      throw StateError('The user returned by Supabase Auth has no email.');
    }

    return AuthUser(id: user.id, email: userEmail);
  }

  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    final session = response.session;
    if (user == null || session == null) {
      throw StateError(
        'Supabase Auth did not establish an authenticated session.',
      );
    }

    final userEmail = user.email;
    if (userEmail == null) {
      throw StateError('The user returned by Supabase Auth has no email.');
    }

    return AuthUser(id: user.id, email: userEmail);
  }

  Future<void> signOut() {
    return _client.auth.signOut();
  }
}
