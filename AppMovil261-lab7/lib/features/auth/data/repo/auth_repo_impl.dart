import 'package:appmovil261/di/dependecy_container.dart';
import 'package:appmovil261/features/auth/data/sources/auth_data_source.dart';
import 'package:appmovil261/features/auth/domain/repo/auth_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepoImpl extends AuthRepo {
  //Inyeccion directa
  final AuthDataSource _source = sl<AuthDataSource>();

  @override
  Future<void> login(String email, String password) async {
    await _source.login(email, password);
    //Debo mapear el objeto que proviene de la web a elementos de mi dominio
  }

  @override
  Future<String> signup(String email, String password) async {
    AuthResponse response = await _source.signup(email, password);
    return response.user!.id;
  }

  @override
  Future<void> logout() async {
    await _source.logout();
  }
}
