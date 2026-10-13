//Es la que se conecta con el exterior
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthDataSource {
  Future<AuthResponse> signup(String email, String password) async {
    AuthResponse response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );
    return response;
  }

  Future<AuthResponse> login(String email, String password) async {
    AuthResponse response = await Supabase.instance.client.auth
        .signInWithPassword(email: email, password: password);
    return response;
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
  }
}
