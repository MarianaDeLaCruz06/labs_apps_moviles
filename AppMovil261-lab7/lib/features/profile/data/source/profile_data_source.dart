import 'package:appmovil261/features/profile/domain/model/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileDataSource {
  //Guardar el perfil
  Future<void> saveProfile(Profile profile) async {
    await Supabase.instance.client.from('profiles').insert(profile.toJson());
  }

  //Obtener el perfil
}
