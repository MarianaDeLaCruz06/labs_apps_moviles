import 'dart:developer' as developer;

import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProfileDataSource {
  final SupabaseClient _client;

  SupabaseProfileDataSource(this._client);

  Future<void> createProfile(Profile profile) async {
    developer.log('Profile insert started.', name: 'registration');

    try {
      await _client.from('profiles').insert({
        'id': profile.id,
        'username': profile.username,
        'full_name': profile.fullName,
      });
      developer.log('Profile insert completed.', name: 'registration');
    } on PostgrestException catch (error) {
      developer.log(
        'Profile insert failed. Code: ${error.code}. '
        'Message: ${error.message}',
        name: 'registration',
        level: 1000,
      );
      rethrow;
    } catch (error) {
      developer.log(
        'Profile insert failed with ${error.runtimeType}.',
        name: 'registration',
        level: 1000,
      );
      rethrow;
    }
  }
}
