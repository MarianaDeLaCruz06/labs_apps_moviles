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

  Future<Profile> getProfile(String id) async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', id)
          .single();

      return Profile(
        id: data['id'] as String,
        username: data['username'] as String,
        fullName: data['full_name'] as String,
      );
    } on PostgrestException catch (error) {
      if (error.code == 'PGRST116') {
        throw StateError('No profile was found for the authenticated user.');
      }
      rethrow;
    }
  }
}
